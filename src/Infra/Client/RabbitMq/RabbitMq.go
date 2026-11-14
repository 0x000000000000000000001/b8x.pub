package Infra_Client_RabbitMq_RabbitMq

import (
	"fmt"
	"net"
	"net/url"
	"strconv"
	"sync"
	"sync/atomic"

	amqp "github.com/rabbitmq/amqp091-go"
)

type rabbitConnection interface {
	Channel() (*amqp.Channel, error)
	Close() error
}

type rabbitChannel interface {
	QueueDeclare(string, bool, bool, bool, bool, amqp.Table) (amqp.Queue, error)
	Publish(string, string, bool, bool, amqp.Publishing) error
	Consume(string, string, bool, bool, bool, bool, amqp.Table) (<-chan amqp.Delivery, error)
	Cancel(string, bool) error
	Close() error
}

var rabbitConsumerID atomic.Uint64

func _CreateConnectionImpl(host string, port int64, user string, password string) (*amqp.Connection, func(), error) {
	address := url.URL{
		Scheme: "amqp",
		User:   url.UserPassword(user, password),
		Host:   net.JoinHostPort(host, strconv.FormatInt(port, 10)),
		Path:   "/",
	}
	connection, err := amqp.Dial(address.String())
	if err != nil {
		return nil, nil, err
	}
	return connection, func() { _ = connection.Close() }, nil
}

func _CreateChannelImpl(connection rabbitConnection) (*amqp.Channel, func(), error) {
	channel, err := connection.Channel()
	if err != nil {
		return nil, nil, err
	}
	return channel, func() { _ = channel.Close() }, nil
}

func _AssertQueueImpl(channel rabbitChannel, queue string) error {
	_, err := channel.QueueDeclare(queue, true, false, false, false, nil)
	return err
}

func _SendToQueueImpl(channel rabbitChannel, queue string, content string) error {
	return channel.Publish("", queue, false, false, amqp.Publishing{
		DeliveryMode: amqp.Persistent,
		Body:         []byte(content),
	})
}

func _ConsumeImpl(channel rabbitChannel, queue string, onMessage func(string)) (func(), error) {
	tag := fmt.Sprintf("b8x-%d", rabbitConsumerID.Add(1))
	messages, err := channel.Consume(queue, tag, true, false, false, false, nil)
	if err != nil {
		return nil, err
	}
	stopped := make(chan struct{})
	var once sync.Once
	cancel := func() {
		once.Do(func() {
			close(stopped)
			_ = channel.Cancel(tag, false)
		})
	}
	go rabbitForwardMessages(messages, stopped, onMessage)
	return cancel, nil
}

// Drain deliveries until the SDK closes them, including after cancellation.
// A callback already in progress may finish after cancellation or channel close.
func rabbitForwardMessages(messages <-chan amqp.Delivery, stopped <-chan struct{}, onMessage func(string)) {
	for message := range messages {
		select {
		case <-stopped:
			continue
		default:
			onMessage(string(message.Body))
		}
	}
}

func _CloseConnectionImpl(connection rabbitConnection) error {
	return connection.Close()
}

func _CloseChannelImpl(channel rabbitChannel) error {
	return channel.Close()
}
