USE panchakarma_hms;

INSERT INTO roles (name, description) VALUES
('admin', 'Full system access'),
('doctor', 'Ayurvedic specialist'),
('therapist', 'Therapy execution role'),
('receptionist', 'Front desk and scheduling'),
('patient', 'Portal access');

INSERT INTO users (role_id, full_name, email, phone, password_hash, email_verified_at) VALUES
(1, 'Admin User', 'admin@panchakarma.local', '9999999991', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(2, 'Dr. Meera Nair', 'doctor@panchakarma.local', '9999999992', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(3, 'Therapist Rahul', 'therapist@panchakarma.local', '9999999993', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(4, 'Reception Desk', 'reception@panchakarma.local', '9999999994', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(5, 'Ananya Menon', 'patient@panchakarma.local', '9999999995', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(2, 'Dr. Arjun Dev', 'doctor2@panchakarma.local', '9999999996', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(3, 'Therapist Neha', 'therapist2@panchakarma.local', '9999999997', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(4, 'Reception Backup', 'reception2@panchakarma.local', '9999999998', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW()),
(5, 'Kiran Nambiar', 'patient2@panchakarma.local', '9999999999', '$2a$10$xaGBmjFch6uTyNdzt1Whg.5VIgJaICyuxswLl9k.5QaKPX1VdS5p.', NOW());

INSERT INTO doctors (user_id, specialization, qualifications, license_number, years_experience, consultation_fee, rating) VALUES
(2, 'Panchakarma and Ayurvedic Internal Medicine', 'BAMS, MD Ayurveda', 'AY-DOC-001', 11, 900, 4.8),
(6, 'Ayurvedic Musculoskeletal Care', 'BAMS, Diploma in Panchakarma', 'AY-DOC-002', 8, 850, 4.6);

INSERT INTO therapists (user_id, certification, skills, availability_json, compatibility_notes, rating) VALUES
(3, 'Certified Panchakarma Therapist', JSON_ARRAY('Abhyanga', 'Shirodhara', 'Nasya'), JSON_OBJECT('mon_fri', '09:00-18:00'), 'Excellent with first-time patients', 4.7),
(7, 'Senior Panchakarma Therapist', JSON_ARRAY('Pizhichil', 'Udwarthanam', 'Kizhi'), JSON_OBJECT('mon_sat', '08:00-17:00'), 'Strong with pain management and detox plans', 4.8);

INSERT INTO patients (
  patient_code, user_id, first_name, last_name, date_of_birth, gender, email, primary_phone,
  emergency_contact_name, emergency_contact_phone, address_line1, city, state, constitution_type,
  allergies, current_medications, medical_history, segment, lifecycle_stage, referral_source
) VALUES
('PAT202604220001', 5, 'Ananya', 'Menon', '1992-08-14', 'Female', 'patient@panchakarma.local', '9999999995', 'Rohit Menon', '9999999996', '12 Palm Grove', 'Kochi', 'Kerala', 'Pitta-Kapha', 'Sesame oil sensitivity', 'Iron supplements', 'Migraine and stress-related insomnia', 'Recurring', 'Treatment', 'Friend referral'),
('PAT202604220002', 9, 'Kiran', 'Nambiar', '1989-01-09', 'Male', 'patient2@panchakarma.local', '9999999999', 'Deepa Nambiar', '8888811111', '4 Green Heights', 'Thrissur', 'Kerala', 'Vata', 'None', 'Vitamin D', 'Back pain after travel', 'Recurring', 'Treatment', 'Website inquiry'),
('PAT202604220003', NULL, 'Vikram', 'Iyer', '1984-03-19', 'Male', 'vikram@example.com', '9999999901', 'Lakshmi Iyer', '9999999902', '8 Lake Road', 'Coimbatore', 'Tamil Nadu', 'Vata', 'None', 'BP medication', 'Chronic cervical stiffness', 'VIP', 'Follow-up', 'Corporate wellness'),
('PAT202604220004', NULL, 'Divya', 'Raman', '1995-11-05', 'Female', 'divya@example.com', '9999999903', 'Hari Raman', '9999999904', '22 River View', 'Bengaluru', 'Karnataka', 'Pitta', 'Dust allergy', 'None', 'PCOS and stress', 'New', 'Intake', 'Instagram'),
('PAT202604220005', NULL, 'Suresh', 'Pillai', '1978-06-17', 'Male', 'suresh@example.com', '9999999905', 'Mini Pillai', '9999999906', '15 Temple Street', 'Kottayam', 'Kerala', 'Kapha', 'Peanut allergy', 'Diabetes medication', 'Weight gain and fatigue', 'Recurring', 'Treatment', 'Doctor referral'),
('PAT202604220006', NULL, 'Megha', 'Varma', '1990-02-22', 'Female', 'megha@example.com', '9999999907', 'Neel Varma', '9999999908', '19 Palm Residency', 'Hyderabad', 'Telangana', 'Vata-Pitta', 'None', 'None', 'Anxiety and poor sleep', 'New', 'Treatment', 'Walk-in'),
('PAT202604220007', NULL, 'Rohan', 'Shetty', '1987-12-30', 'Male', 'rohan@example.com', '9999999909', 'Pooja Shetty', '9999999910', '87 Hill Crest', 'Mangaluru', 'Karnataka', 'Kapha', 'None', 'None', 'Sinus congestion and low immunity', 'Recurring', 'Follow-up', 'Google search'),
('PAT202604220008', NULL, 'Lakshmi', 'Narayan', '1969-09-15', 'Female', 'lakshmi@example.com', '9999999911', 'Arun Narayan', '9999999912', '5 Lotus Enclave', 'Chennai', 'Tamil Nadu', 'Pitta-Kapha', 'None', 'Thyroid medication', 'Joint stiffness and low energy', 'VIP', 'Treatment', 'Existing patient family'),
('PAT202604220009', NULL, 'Amit', 'Joshi', '1993-04-12', 'Male', 'amit@example.com', '9999999913', 'Rekha Joshi', '9999999914', '31 Sunrise Park', 'Pune', 'Maharashtra', 'Vata', 'None', 'None', 'Sports recovery and muscle tightness', 'New', 'Intake', 'Gym referral'),
('PAT202604220010', NULL, 'Pooja', 'Das', '1988-07-08', 'Female', 'pooja@example.com', '9999999915', 'Mohan Das', '9999999916', '40 Bay Garden', 'Kozhikode', 'Kerala', 'Tri-dosha', 'None', 'Calcium supplement', 'Chronic fatigue', 'Recurring', 'Treatment', 'YouTube campaign'),
('PAT202604220011', NULL, 'Naveen', 'Kumar', '1975-05-25', 'Male', 'naveen@example.com', '9999999917', 'Ritu Kumar', '9999999918', '11 Oak Residency', 'Mysuru', 'Karnataka', 'Kapha', 'None', 'Cholesterol medication', 'Obesity management', 'VIP', 'Treatment', 'Corporate camp'),
('PAT202604220012', NULL, 'Sneha', 'Mathew', '1998-10-01', 'Female', 'sneha@example.com', '9999999919', 'Thomas Mathew', '9999999920', '99 Garden Lane', 'Alappuzha', 'Kerala', 'Pitta', 'None', 'None', 'Hair fall and stress', 'New', 'Follow-up', 'Beauty clinic referral');

INSERT INTO therapies (
  name, category, duration_minutes, cost_per_session, required_items_json, precautions, contraindications,
  benefits, indications, skill_level_required
) VALUES
('Abhyanga', 'Massage Therapy', 60, 1800, JSON_ARRAY('Dhanwantharam Tailam', 'Warm towels'), 'Avoid immediately after meals', 'High fever', 'Deep relaxation and improved circulation', 'Stress, fatigue, dry skin', 'Intermediate'),
('Shirodhara', 'Mind-Body Therapy', 45, 2200, JSON_ARRAY('Ksheerabala Tailam'), 'Ensure eye protection', 'Recent head trauma', 'Calms the nervous system', 'Anxiety, sleep disturbance', 'Advanced'),
('Nasya', 'Detox Therapy', 30, 1200, JSON_ARRAY('Anu Tailam'), 'Not during acute cold', 'Nasal bleeding', 'Supports sinus clarity', 'Migraine, sinus congestion', 'Intermediate'),
('Pizhichil', 'Oil Therapy', 75, 2600, JSON_ARRAY('Warm herbal oil', 'Linen towels'), 'Rest after therapy', 'Severe indigestion', 'Lubricates joints and supports recovery', 'Arthritis, stiffness', 'Advanced'),
('Udwarthanam', 'Powder Therapy', 50, 1700, JSON_ARRAY('Herbal powder'), 'Hydrate well', 'Sensitive skin lesions', 'Supports weight management', 'Obesity, kapha imbalance', 'Intermediate'),
('Kizhi', 'Bolus Therapy', 55, 2100, JSON_ARRAY('Medicinal bolus', 'Castor oil'), 'Avoid cold exposure', 'Open wounds', 'Relieves pain and improves mobility', 'Muscle pain, stiffness', 'Advanced'),
('Takradhara', 'Cooling Therapy', 45, 2000, JSON_ARRAY('Medicated buttermilk'), 'Protect eyes', 'Acute sinus infection', 'Cools pitta and relaxes the mind', 'Stress, scalp heat, insomnia', 'Advanced'),
('Basti', 'Detox Therapy', 40, 2500, JSON_ARRAY('Medicated enema oils'), 'Clinical screening required', 'Pregnancy', 'Improves vata disorders', 'Constipation, neurological issues', 'Advanced');

INSERT INTO packages (
  name, package_type, description, duration_days, total_cost, discount_type, discount_value,
  inclusions, expected_outcomes, customization_options, seasonal_offer_note
) VALUES
('Detox Package', 'Purification', 'Core cleansing plan with detoxifying therapies', 14, 24000, 'Percentage', 10, 'Meals, consultation, herbal tea', 'Improved digestion and reduced ama', 'Swap one therapy based on condition', 'Monsoon wellness offer'),
('Stress Relief Package', 'Rasayana', 'Relaxation and sleep support package', 10, 18000, 'Fixed', 1500, 'Consultation, meditation session', 'Better sleep and reduced anxiety', 'Add yoga session', 'Festival season recovery'),
('Weight Management Package', 'Wellness', 'Kapha-balancing therapy plan with powder and oil treatments', 12, 22000, 'Percentage', 8, 'Diet sheet, herbal tea', 'Better metabolism and lightness', 'Custom meal support', 'Summer transformation camp'),
('Pain Relief Package', 'Rehabilitation', 'Joint and muscle recovery package', 9, 19500, 'Fixed', 1200, 'Consultation and mobility review', 'Pain relief and improved movement', 'Add physiotherapy review', 'Senior care week');

INSERT INTO package_therapies (package_id, therapy_id, frequency_per_week) VALUES
(1, 1, 4),
(1, 3, 2),
(1, 8, 1),
(2, 1, 3),
(2, 2, 3),
(2, 7, 2),
(3, 5, 4),
(3, 1, 2),
(4, 4, 3),
(4, 6, 3);

INSERT INTO treatment_plans (
  patient_id, doctor_id, package_id, diagnosis, condition_details, recommended_therapies,
  treatment_duration_weeks, precautions, contraindications, expected_outcomes, success_metrics,
  status, start_date, end_date
) VALUES
(1, 1, 2, 'Stress-induced sleep disturbance', 'High work stress with migraine tendency', JSON_ARRAY('Abhyanga', 'Shirodhara'), 4, 'Keep hydrated and avoid cold exposure after therapy', 'Monitor for sesame oil sensitivity', 'Sleep duration above 7 hours, lower headache frequency', 'Weekly sleep score and migraine diary', 'Active', '2026-04-20', '2026-05-18'),
(2, 2, 4, 'Postural lower back pain', 'Travel fatigue and muscle tightness', JSON_ARRAY('Kizhi', 'Pizhichil'), 3, 'Do gentle stretching daily', 'Avoid heavy gym activity', 'Improved flexibility and pain relief', 'Pain score reduction', 'Active', '2026-04-18', '2026-05-09'),
(3, 1, 4, 'Vata aggravation with neck stiffness', 'Sedentary work and poor posture', JSON_ARRAY('Abhyanga', 'Nasya'), 3, 'Daily stretching exercises', 'Avoid therapy during acute fever', 'Reduced stiffness and improved range of motion', 'Pain score reduction by 50%', 'Active', '2026-04-18', '2026-05-09'),
(4, 1, 2, 'Hormonal stress with irregular cycles', 'High stress and pitta aggravation', JSON_ARRAY('Shirodhara', 'Takradhara'), 4, 'Avoid spicy foods', 'Screen for severe anemia', 'Better calmness and cycle regularity', 'Symptom reduction chart', 'Draft', '2026-04-24', '2026-05-22'),
(5, 2, 3, 'Kapha obesity and fatigue', 'Slow metabolism and heaviness', JSON_ARRAY('Udwarthanam', 'Abhyanga'), 5, 'Follow diet plan', 'Stop during skin irritation', 'Weight and inch loss', 'Weekly weight measurement', 'Active', '2026-04-15', '2026-05-20'),
(6, 1, 2, 'Anxiety and insomnia', 'Long working hours and stress', JSON_ARRAY('Shirodhara', 'Abhyanga'), 4, 'Reduce screen time at night', 'Avoid late dinners', 'Improved sleep and relaxation', 'Sleep score', 'Active', '2026-04-21', '2026-05-19'),
(8, 2, 4, 'Arthritic stiffness', 'Morning stiffness and low mobility', JSON_ARRAY('Pizhichil', 'Kizhi'), 4, 'Warm water bath after sessions', 'Avoid cold foods', 'Improved mobility', 'Mobility scale improvement', 'Active', '2026-04-16', '2026-05-14'),
(11, 2, 3, 'Metabolic weight management', 'Corporate wellness program follow-up', JSON_ARRAY('Udwarthanam', 'Abhyanga'), 6, 'Hydration and diet adherence', 'Monitor BP weekly', 'Weight and energy improvement', 'BMI trend and energy score', 'Active', '2026-04-10', '2026-05-25');

INSERT INTO appointments (
  patient_id, treatment_plan_id, therapy_id, therapist_id, appointment_date, visit_type, status, notes, buffer_minutes
) VALUES
(1, 1, 2, 1, '2026-04-18 10:00:00', 'Therapy Session', 'Completed', 'Opening Shirodhara session', 20),
(3, 3, 3, 1, '2026-04-19 15:00:00', 'Therapy Session', 'Scheduled', 'Nasya for sinus and stiffness support', 15),
(5, 5, 5, 2, '2026-04-20 09:30:00', 'Therapy Session', 'Completed', 'First Udwarthanam session', 15),
(6, 6, 2, 1, '2026-04-21 11:00:00', 'Therapy Session', 'Completed', 'Stress management session', 20),
(8, 7, 4, 2, '2026-04-22 16:00:00', 'Therapy Session', 'Completed', 'Joint mobility therapy', 20),
(1, 1, 1, 1, '2026-04-23 11:00:00', 'Therapy Session', 'Scheduled', 'Follow-up Abhyanga', 15),
(2, 2, 6, 2, '2026-04-23 14:00:00', 'Therapy Session', 'Scheduled', 'Pain relief bolus treatment', 15),
(3, 3, 1, 1, '2026-04-24 09:00:00', 'Therapy Session', 'Completed', 'Abhyanga for neck stiffness', 15),
(4, 4, 7, 1, '2026-04-24 13:00:00', 'Consultation', 'Scheduled', 'Cooling therapy review', 15),
(5, 5, 1, 2, '2026-04-24 16:30:00', 'Therapy Session', 'Completed', 'Supportive Abhyanga session', 15),
(6, 6, 1, 1, '2026-04-25 10:30:00', 'Therapy Session', 'Scheduled', 'Relaxation massage', 15),
(7, NULL, 3, 1, '2026-04-25 15:30:00', 'Walk-in', 'No-show', 'Booked for sinus care', 10),
(8, 7, 6, 2, '2026-04-26 11:30:00', 'Therapy Session', 'Scheduled', 'Kizhi mobility session', 15),
(9, NULL, 4, 2, '2026-04-27 09:30:00', 'Consultation', 'Cancelled', 'Pain assessment booking', 15),
(10, NULL, 2, 1, '2026-04-28 14:00:00', 'Therapy Session', 'Scheduled', 'Stress and fatigue support', 15),
(11, 8, 5, 2, '2026-04-29 08:30:00', 'Therapy Session', 'Scheduled', 'Weight management session', 15),
(12, NULL, 1, 1, '2026-05-01 12:00:00', 'Consultation', 'Scheduled', 'Initial assessment visit', 15),
(2, 2, 4, 2, '2026-05-03 10:00:00', 'Therapy Session', 'Scheduled', 'Follow-up oil therapy', 20);

INSERT INTO therapy_sessions (
  appointment_id, session_date, status, observations, patient_comfort_rating, therapist_notes, recommendations
) VALUES
(1, '2026-04-18 10:00:00', 'Completed', 'Patient relaxed well after the first session', 5, 'Tolerated therapy comfortably', 'Continue sleep diary'),
(3, '2026-04-20 09:30:00', 'Completed', 'Powder therapy tolerated well', 4, 'Good response from first session', 'Increase warm water intake'),
(4, '2026-04-21 11:00:00', 'Completed', 'Calming effect observed', 5, 'Reported better sleep same evening', 'Repeat after 3 days'),
(5, '2026-04-22 16:00:00', 'Completed', 'Joint stiffness reduced post session', 4, 'Good heat response', 'Do mobility exercises'),
(8, '2026-04-24 09:00:00', 'Completed', 'Muscle stiffness reduced', 4, 'Patient felt lighter after massage', 'Continue neck stretches'),
(10, '2026-04-24 16:30:00', 'Completed', 'Supportive session helped fatigue', 4, 'No adverse reaction', 'Follow package diet sheet');

INSERT INTO suppliers (name, contact_person, phone, email, payment_terms, quality_feedback) VALUES
('Kerala Ayurveda Supplies', 'Sanjay Pillai', '8888888801', 'sales@kerala-ayur.local', '30 days credit', 'Reliable oil quality'),
('Herbal Essence Traders', 'Nisha R', '8888888802', 'hello@herbal.local', 'Advance 50%', 'Fast delivery'),
('Ayur Herb Logistics', 'Pradeep K', '8888888803', 'care@ayurherb.local', '15 days credit', 'Good packaging and quality'),
('Wellness Root Pharma', 'Amala S', '8888888804', 'orders@wellnessroot.local', 'Immediate payment', 'Consistent medicinal stock');

INSERT INTO inventory_items (
  item_name, item_type, batch_number, cost_per_unit, selling_price, quantity_in_stock, unit,
  expiry_date, supplier_id, storage_location, low_stock_threshold
) VALUES
('Dhanwantharam Tailam', 'Oil', 'DT-APR-26', 2.50, 4.50, 1200, 'ml', '2027-01-31', 1, 'Oil Rack A', 300),
('Ksheerabala Tailam', 'Oil', 'KT-APR-26', 3.20, 5.20, 650, 'ml', '2026-12-15', 1, 'Oil Rack B', 200),
('Anu Tailam', 'Medicine', 'AT-APR-26', 1.10, 2.80, 180, 'ml', '2026-10-20', 2, 'Medicine Cabinet 2', 100),
('Herbal Powder Mix', 'Powder', 'HPM-APR-26', 0.90, 2.10, 900, 'gm', '2026-11-30', 3, 'Powder Shelf 1', 250),
('Pizhichil Oil Blend', 'Oil', 'POB-MAY-26', 4.80, 7.50, 540, 'ml', '2027-02-10', 1, 'Oil Rack C', 180),
('Kizhi Poultice Pack', 'Consumable', 'KPP-MAY-26', 35.00, 60.00, 75, 'pcs', '2026-09-30', 4, 'Therapy Store 2', 30),
('Takra Base Mix', 'Consumable', 'TBM-MAY-26', 1.75, 3.50, 220, 'ml', '2026-08-20', 3, 'Cooling Shelf', 80),
('Basti Kit', 'Consumable', 'BK-MAY-26', 55.00, 90.00, 40, 'pcs', '2026-12-31', 4, 'Procedure Cabinet', 15);

INSERT INTO session_inventory_usage (therapy_session_id, inventory_item_id, quantity_used) VALUES
(1, 2, 30),
(2, 4, 80),
(3, 2, 25),
(4, 5, 40),
(5, 1, 35),
(6, 1, 28);

INSERT INTO bills (
  patient_id, appointment_id, invoice_number, bill_date, subtotal, tax_amount, discount_amount,
  previous_pending_amount, net_amount, amount_paid, pending_amount, status, payment_terms
) VALUES
(1, 1, 'INV-2026-0001', '2026-04-18', 2200, 396, 100, 0, 0, 0, 0, 'Pending', 'Due within 7 days'),
(5, 3, 'INV-2026-0002', '2026-04-20', 1700, 306, 0, 0, 0, 0, 0, 'Pending', 'Due on completion'),
(6, 4, 'INV-2026-0003', '2026-04-21', 2200, 396, 200, 0, 0, 0, 0, 'Pending', 'Due within 5 days'),
(8, 5, 'INV-2026-0004', '2026-04-22', 2600, 468, 0, 0, 0, 0, 0, 'Pending', 'Due on completion'),
(3, 8, 'INV-2026-0005', '2026-04-24', 1800, 324, 0, 0, 0, 0, 0, 'Pending', 'Due within 7 days'),
(5, 10, 'INV-2026-0006', '2026-04-24', 1800, 324, 150, 0, 0, 0, 0, 'Pending', 'Due within 7 days');

INSERT INTO payments (bill_id, amount_paid, payment_mode, reference_number, received_by_user_id, notes) VALUES
(1, 1500, 'UPI', 'UPI123456', 4, 'Advance collected'),
(2, 2006, 'Cash', 'CASH2006', 4, 'Paid at reception'),
(3, 1000, 'Card', 'CARD1000', 8, 'Partial card payment'),
(5, 2124, 'Bank Transfer', 'BT2124', 4, 'Transferred by patient');

INSERT INTO feedback (patient_id, therapy_session_id, therapist_id, rating, facility_rating, comment, improvement_metrics, consent_for_testimonial) VALUES
(1, 1, 1, 5, 5, 'Very calming session and attentive therapist', JSON_OBJECT('sleep_score', 8, 'stress_score', 4), 1),
(5, 2, 2, 4, 4, 'Felt lighter after the powder therapy', JSON_OBJECT('energy_score', 7, 'weight_trend', -1.2), 0),
(6, 3, 1, 5, 5, 'Excellent relaxation and smoother sleep', JSON_OBJECT('sleep_score', 9, 'anxiety_score', 3), 1),
(8, 4, 2, 4, 4, 'Joint pain reduced after session', JSON_OBJECT('pain_score', 5, 'mobility_score', 7), 0),
(3, 5, 1, 4, 5, 'Neck stiffness reduced noticeably', JSON_OBJECT('pain_score', 4, 'range_of_motion', 8), 0),
(5, 6, 2, 4, 4, 'Good supportive therapy for fatigue', JSON_OBJECT('energy_score', 8, 'comfort_score', 8), 0);
