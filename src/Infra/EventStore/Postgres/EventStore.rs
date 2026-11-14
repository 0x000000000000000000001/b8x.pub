use std::sync::{Mutex, OnceLock};

struct LockKeyState {
    process_id: u16,
    counter: u16,
}

impl LockKeyState {
    fn next(&mut self, milliseconds: u128) -> String {
        self.counter = (self.counter + 1) % 1000;
        format!("{milliseconds}{:03}{:03}", self.process_id, self.counter)
    }
}

pub fn Infra_EventStore_Postgres_EventStore_generateLockKeyStr() -> crate::UnknownType {
    purust_core::Value::Func1(purust_core::Func1::Static(|_| {
        // Match the JS process-wide random suffix and modulo-1000 sequence.
        // Serialize the clock read with the counter, including in Arc mode.
        static STATE: OnceLock<Mutex<LockKeyState>> = OnceLock::new();
        let mut state = STATE.get_or_init(|| Mutex::new(LockKeyState {
            process_id: rand::random_range(0..1000), counter: 0,
        })).lock().expect("lock key state poisoned");
        let milliseconds = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH).expect("clock predates Unix epoch").as_millis();
        purust_core::Value::String(state.next(milliseconds))
    }))
}

#[cfg(test)]
mod lock_key_tests {
    use super::*;

    #[test]
    fn format_and_wrap_match_js() {
        let mut state = LockKeyState { process_id: 7, counter: 0 };
        assert_eq!(state.next(1720000000000), "1720000000000007001");
        for counter in 2..=1000 {
            assert_eq!(state.next(1720000000000), format!("1720000000000007{:03}", counter % 1000));
        }
        assert_eq!(state.next(1720000000001), "1720000000001007001");
    }

    #[test]
    fn effect_replay_reads_clock_and_advances_shared_counter() {
        let action = Infra_EventStore_Postgres_EventStore_generateLockKeyStr();
        let run = |action: purust_core::Value| action.unwrap_func1()(purust_core::Value::Unit).unwrap_string();
        let first = run(action.clone());
        std::thread::sleep(std::time::Duration::from_millis(5));
        let second = run(action);
        let third = run(Infra_EventStore_Postgres_EventStore_generateLockKeyStr());
        let split = first.len() - 6;
        assert!(second[..split].parse::<u128>().unwrap() > first[..split].parse::<u128>().unwrap());
        assert_eq!(&first[split..split+3], &second[split..split+3]);
        assert_eq!(&second[split..split+3], &third[split..split+3]);
        assert_eq!(second[split+3..].parse::<u16>().unwrap(), (first[split+3..].parse::<u16>().unwrap() + 1) % 1000);
        assert_eq!(third[split+3..].parse::<u16>().unwrap(), (second[split+3..].parse::<u16>().unwrap() + 1) % 1000);
        assert!(third.parse::<i64>().is_ok());
    }
}
