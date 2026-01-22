use std::collections::{HashMap, HashSet};

pub type Time = u64;
pub type ActionId = [u8; 32];
pub type IntentId = [u8; 32];

#[derive(Clone, Copy)]
pub struct Intent {
    pub id: IntentId,
    pub action: ActionId,
    pub deadline: Time,
}

#[derive(Default)]
pub struct Kernel {
    pub current_time: Time,
    intents: HashMap<IntentId, Intent>,
    observations: HashMap<ActionId, Time>, // earliest observation only
    absences: HashSet<IntentId>,            // monotonic
}

impl Kernel {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn declare_intent(&mut self, intent: Intent) {
        assert!(intent.deadline > self.current_time);
        self.intents.insert(intent.id, intent);
    }

    pub fn observe_action(&mut self, action: ActionId, time: Time) {
        // No late action allowed
        for intent in self.intents.values() {
            if intent.action == action {
                assert!(time < intent.deadline);
            }
        }
        self.observations
            .entry(action)
            .and_modify(|t| *t = (*t).min(time))
            .or_insert(time);
    }

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
            if self.current_time >= intent.deadline && !self.was_observed(intent) {
                self.absences.insert(*id);
            }
        }
    }

    fn was_observed(&self, intent: &Intent) -> bool {
        match self.observations.get(&intent.action) {
            None => false,
            Some(t) => *t <= inten*
