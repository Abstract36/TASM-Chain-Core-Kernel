#![no_std]

extern crate alloc;

use alloc::collections::{BTreeMap, BTreeSet};

pub type Time = u64;
pub type ActionId = [u8; 32];
pub type IntentId = [u8; 32];

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct Intent {
    pub id: IntentId,
    pub action: ActionId,
    pub deadline: Time,
}

pub struct Kernel {
    current_time: Time,
    intents: BTreeMap<IntentId, Intent>,
    observations: BTreeMap<ActionId, Time>, // earliest only
    absences: BTreeSet<IntentId>,            // monotonic
}

impl Kernel {
    pub fn new() -> Self {
        Self {
            current_time: 0,
            intents: BTreeMap::new(),
            observations: BTreeMap::new(),
            absences: BTreeSet::new(),
        }
    }

    pub fn current_time(&self) -> Time {
        self.current_time
    }

    /// Declare an intent: (action, deadline)
    /// Introduces a future point of impossibility.
    pub fn declare_intent(&mut self, intent: Intent) {
        assert!(intent.deadline > self.current_time);
        self.intents.insert(intent.id, intent);
    }

    /// Observe an action before its deadline.
    /// Prevents Absence from becoming true.
    pub fn observe_action(&mut self, action: ActionId, time: Time) {
        for intent in self.intents.values() {
            if intent.action == action {
                assert!(time < intent.deadline);
            }
        }

        self.observations
            .entry(action)
            .and_modify(|t| {
                if time < *t {
                    *t = time;
                }
            })
            .or_insert(time);
    }

    /// Advance monotonic time.
    /// This is the ONLY state transition driver.
    pub fn advance_time(&mut self, to: Time) {
        assert!(to >= self.current_time);
        self.current_time = to;
        self.compute_absences();
    }

    fn compute_absences(&mut self) {
        for (id, intent) in self.intents.iter() {
            if self.absences.contains(id) {
                continue;
            }

            if self.current_time >= intent.deadline
                && !self.was_observed(intent)
            {
                self.absences.insert(*id);
            }
        }
    }

    fn was_observed(&self, intent: &Intent) -> bool {
        match self.observations.get(&intent.action) {
            None => false,
            Some(t) => *t <= intent.deadline,
        }
    }

    /// Read-only view of Absence set
    pub fn absences(&self) -> &BTreeSet<IntentId> {
        &self.absences
    }
}
