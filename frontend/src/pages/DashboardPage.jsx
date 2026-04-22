import { useEffect, useMemo, useState } from "react";
import client from "../api/client";
import { useAuth } from "../context/AuthContext";
import MetricCard from "../components/MetricCard";
import DataTable from "../components/DataTable";
import ActionCard from "../components/ActionCard";
import { FormField, SelectField, TextAreaField } from "../components/FormField";

const roleMessages = {
  admin: "System-wide operations, finance control, inventory monitoring, and activity supervision.",
  doctor: "Patient review, treatment planning, and clinical progress management.",
  therapist: "Session execution, treatment logging, and therapy inventory usage.",
  receptionist: "Patient registration, booking, schedule management, and payment follow-up.",
  patient: "Your appointments, treatment journey, and billing updates in one place."
};

const emptyPatientForm = {
  firstName: "",
  lastName: "",
  dateOfBirth: "",
  gender: "Female",
  email: "",
  primaryPhone: "",
  city: "",
  state: "",
  constitutionType: "Vata",
  allergies: "",
  currentMedications: "",
  medicalHistory: "",
  segment: "New",
  lifecycleStage: "Intake",
  referralSource: ""
};

const emptyAppointmentForm = {
  patientId: "",
  treatmentPlanId: "",
  therapyId: "",
  therapistId: "",
  appointmentDate: "",
  visitType: "Therapy Session",
  notes: "",
  bufferMinutes: 15
};

const emptyTreatmentPlanForm = {
  patientId: "",
  doctorId: "1",
  packageId: "",
  diagnosis: "",
  conditionDetails: "",
  recommendedTherapies: "",
  treatmentDurationWeeks: "",
  precautions: "",
  contraindications: "",
  expectedOutcomes: "",
  successMetrics: "",
  status: "Draft",
  startDate: "",
  endDate: ""
};

const emptySessionForm = {
  appointmentId: "",
  sessionDate: "",
  observations: "",
  patientComfortRating: 4,
  therapistNotes: "",
  recommendations: ""
};

const emptyInventoryUsageForm = {
  therapySessionId: "",
  inventoryItemId: "",
  quantityUsed: ""
};

const emptyBillForm = {
  appointmentId: "",
  discountAmount: 0,
  previousPendingAmount: 0,
  paymentTerms: "Due on completion"
};

const emptyPaymentForm = {
  billId: "",
  amountPaid: "",
  paymentMode: "UPI",
  referenceNumber: "",
  notes: ""
};

function fmtDate(value) {
  if (!value) return "-";
  return new Date(value).toLocaleString();
}

function isToday(value) {
  if (!value) return false;
  const date = new Date(value);
  const today = new Date();
  return date.toDateString() === today.toDateString();
}

export default function DashboardPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState({ type: "", text: "" });
  const [overview, setOverview] = useState(null);
  const [patients, setPatients] = useState([]);
  const [appointments, setAppointments] = useState([]);
  const [bills, setBills] = useState([]);
  const [treatmentPlans, setTreatmentPlans] = useState([]);
  const [sessions, setSessions] = useState([]);
  const [therapies, setTherapies] = useState([]);
  const [packages, setPackages] = useState([]);
  const [inventory, setInventory] = useState([]);
  const [activityLogs, setActivityLogs] = useState([]);
  const [patientPortal, setPatientPortal] = useState(null);
  const [patientForm, setPatientForm] = useState(emptyPatientForm);
  const [appointmentForm, setAppointmentForm] = useState(emptyAppointmentForm);
  const [treatmentPlanForm, setTreatmentPlanForm] = useState(emptyTreatmentPlanForm);
  const [sessionForm, setSessionForm] = useState(emptySessionForm);
  const [inventoryUsageForm, setInventoryUsageForm] = useState(emptyInventoryUsageForm);
  const [billForm, setBillForm] = useState(emptyBillForm);
  const [paymentForm, setPaymentForm] = useState(emptyPaymentForm);
  const [editingPatientId, setEditingPatientId] = useState(null);
  const [editingTreatmentPlanId, setEditingTreatmentPlanId] = useState(null);

  async function loadDashboard() {
    setLoading(true);
    try {
      if (user?.role === "patient") {
        const [portalRes, appointmentRes] = await Promise.all([
          client.get("/patients/portal/me"),
          client.get("/appointments")
        ]);
        setPatientPortal(portalRes.data);
        setAppointments(appointmentRes.data);
        setBills(portalRes.data.bills || []);
        setTreatmentPlans(portalRes.data.treatmentTimeline || []);
        setSessions(
          (portalRes.data.treatmentTimeline || [])
            .filter((item) => item.session_status)
            .map((item, index) => ({
              id: `${item.patient_code}-${index}`,
              therapy_name: item.therapy_name,
              status: item.session_status,
              appointment_date: item.appointment_date,
              patient_name: item.patient_name
            }))
        );
      } else {
        const requests = [
          client.get("/reports/overview"),
          client.get("/patients"),
          client.get("/appointments"),
          client.get("/billing/bills"),
          client.get("/therapies"),
          client.get("/packages"),
          client.get("/sessions"),
          client.get("/inventory"),
          client.get("/doctors/treatment-plans")
        ];

        if (user?.role === "admin") {
          requests.push(client.get("/reports/activity"));
        }

        const responses = await Promise.allSettled(requests);
        const [
          overviewRes,
          patientRes,
          appointmentRes,
          billRes,
          therapyRes,
          packageRes,
          sessionRes,
          inventoryRes,
          treatmentPlanRes,
          activityRes
        ] = responses;

        if (overviewRes?.status === "fulfilled") setOverview(overviewRes.value.data);
        if (patientRes?.status === "fulfilled") setPatients(patientRes.value.data);
        if (appointmentRes?.status === "fulfilled") setAppointments(appointmentRes.value.data);
        if (billRes?.status === "fulfilled") setBills(billRes.value.data);
        if (therapyRes?.status === "fulfilled") setTherapies(therapyRes.value.data);
        if (packageRes?.status === "fulfilled") setPackages(packageRes.value.data);
        if (sessionRes?.status === "fulfilled") setSessions(sessionRes.value.data);
        if (inventoryRes?.status === "fulfilled") setInventory(inventoryRes.value.data);
        if (treatmentPlanRes?.status === "fulfilled") setTreatmentPlans(treatmentPlanRes.value.data);
        if (activityRes?.status === "fulfilled") setActivityLogs(activityRes.value.data);
      }
    } catch (error) {
      setMessage({ type: "error", text: error.response?.data?.message || "Failed to load dashboard" });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (user) {
      loadDashboard();
    }
  }, [user]);

  const patientOptions = useMemo(
    () => patients.map((patient) => ({ value: patient.id, label: `${patient.full_name} (${patient.patient_code})` })),
    [patients]
  );

  const appointmentActions =
    user?.role === "admin" || user?.role === "receptionist" || user?.role === "doctor"
      ? (row) => {
          const actions = [];

          if (!["Completed", "Cancelled", "No-show"].includes(row.status)) {
            actions.push({
              label: "Mark Completed",
              onClick: () => handleAppointmentStatus(row.id, "Completed"),
              disabled: busy
            });
          }

          if (!["Completed", "Cancelled"].includes(row.status)) {
            actions.push({
              label: "Cancel",
              onClick: () => handleAppointmentStatus(row.id, "Cancelled"),
              variant: "danger",
              disabled: busy
            });
          }

          if (!["Completed", "In Progress"].includes(row.status)) {
            actions.push({
              label: "Delete",
              onClick: () => handleAppointmentDelete(row.id),
              variant: "danger",
              disabled: busy
            });
          }

          if (!actions.length) {
            actions.push({
              label: "Locked",
              onClick: () => {},
              disabled: true
            });
          }

          return actions;
        }
      : null;

  const summaryCards = useMemo(() => {
    if (user?.role === "patient" && patientPortal) {
      return [
        { label: "Upcoming Appointments", value: patientPortal.stats.upcomingAppointments },
        { label: "Active Treatments", value: patientPortal.stats.activeTreatments, accent: "text-brand-clay" },
        { label: "Pending Bills", value: patientPortal.stats.pendingBills },
        { label: "Completed Sessions", value: patientPortal.stats.completedSessions, accent: "text-red-600" }
      ];
    }

    const stats = overview?.stats || {
      patients: 0,
      upcomingAppointments: 0,
      pendingReceivables: 0,
      inventoryAlerts: 0
    };

    if (user?.role === "doctor") {
      return [
        { label: "Active Plans", value: treatmentPlans.filter((item) => item.status === "Active").length },
        { label: "Today's Appointments", value: appointments.filter((item) => isToday(item.appointment_date)).length, accent: "text-brand-clay" },
        { label: "Patient Load", value: new Set(treatmentPlans.map((item) => item.patient_name)).size },
        { label: "Recent Sessions", value: sessions.filter((item) => item.status === "Completed").length, accent: "text-red-600" }
      ];
    }

    if (user?.role === "therapist") {
      return [
        { label: "Today's Sessions", value: appointments.filter((item) => isToday(item.appointment_date)).length },
        { label: "Pending Sessions", value: appointments.filter((item) => item.status === "Scheduled").length, accent: "text-brand-clay" },
        { label: "Completed Sessions", value: sessions.filter((item) => item.status === "Completed").length },
        { label: "Inventory Alerts", value: inventory.filter((item) => item.stock_status !== "Healthy").length, accent: "text-red-600" }
      ];
    }

    if (user?.role === "receptionist") {
      return [
        { label: "Today's Appointments", value: appointments.filter((item) => isToday(item.appointment_date)).length },
        { label: "Registered Patients", value: patients.length, accent: "text-brand-clay" },
        { label: "Pending Bills", value: bills.filter((item) => item.status !== "Paid").length },
        { label: "Needs Attention", value: appointments.filter((item) => item.status === "Scheduled").length, accent: "text-red-600" }
      ];
    }

    return [
      { label: "Patients", value: stats.patients },
      { label: "Today's Appointments", value: appointments.filter((item) => isToday(item.appointment_date)).length, accent: "text-brand-clay" },
      { label: "Pending Receivables", value: `Rs ${stats.pendingReceivables}` },
      { label: "Inventory Alerts", value: stats.inventoryAlerts, accent: "text-red-600" }
    ];
  }, [user, patientPortal, overview, treatmentPlans, appointments, sessions, inventory, patients, bills]);

  async function submitAction(action, successMessage) {
    setBusy(true);
    setMessage({ type: "", text: "" });
    try {
      await action();
      setMessage({ type: "success", text: successMessage });
      await loadDashboard();
    } catch (error) {
      setMessage({ type: "error", text: error.response?.data?.message || "Action failed" });
    } finally {
      setBusy(false);
    }
  }

  function beginEditPatient(patient) {
    setEditingPatientId(patient.id);
    setPatientForm({
      firstName: patient.full_name.split(" ").slice(0, -1).join(" ") || patient.full_name,
      lastName: patient.full_name.split(" ").slice(-1).join(" "),
      dateOfBirth: "",
      gender: patient.gender || "Female",
      email: patient.email || "",
      primaryPhone: patient.primary_phone || "",
      city: patient.city || "",
      state: patient.state || "",
      constitutionType: patient.constitution_type || "Vata",
      allergies: "",
      currentMedications: "",
      medicalHistory: "",
      segment: patient.segment || "New",
      lifecycleStage: patient.lifecycle_stage || "Intake",
      referralSource: ""
    });
  }

  function beginEditTreatmentPlan(plan) {
    setEditingTreatmentPlanId(plan.id);
    setTreatmentPlanForm({
      patientId: patientOptions.find((option) => option.label.includes(plan.patient_name))?.value || "",
      doctorId: "1",
      packageId: "",
      diagnosis: plan.diagnosis || "",
      conditionDetails: "",
      recommendedTherapies: "",
      treatmentDurationWeeks: "",
      precautions: "",
      contraindications: "",
      expectedOutcomes: "",
      successMetrics: "",
      status: plan.status || "Draft",
      startDate: plan.start_date?.slice(0, 10) || "",
      endDate: plan.end_date?.slice(0, 10) || ""
    });
  }

  async function handlePatientSubmit(event) {
    event.preventDefault();
    const payload = { ...patientForm };
    await submitAction(
      () => (editingPatientId ? client.put(`/patients/${editingPatientId}`, payload) : client.post("/patients", payload)),
      editingPatientId ? "Patient updated successfully" : "Patient registered successfully"
    );
    setEditingPatientId(null);
    setPatientForm(emptyPatientForm);
  }

  async function handleAppointmentSubmit(event) {
    event.preventDefault();
    await submitAction(
      () =>
        client.post("/appointments", {
          ...appointmentForm,
          patientId: Number(appointmentForm.patientId),
          treatmentPlanId: appointmentForm.treatmentPlanId ? Number(appointmentForm.treatmentPlanId) : null,
          therapyId: appointmentForm.therapyId ? Number(appointmentForm.therapyId) : null,
          therapistId: appointmentForm.therapistId ? Number(appointmentForm.therapistId) : null
        }),
      "Appointment created successfully"
    );
    setAppointmentForm(emptyAppointmentForm);
  }

  async function handleAppointmentStatus(id, status) {
    await submitAction(() => client.patch(`/appointments/${id}/status`, { status }), `Appointment moved to ${status}`);
  }

  async function handleAppointmentDelete(id) {
    await submitAction(() => client.delete(`/appointments/${id}`), "Appointment deleted successfully");
  }

  async function handleTreatmentPlanSubmit(event) {
    event.preventDefault();
    const payload = {
      ...treatmentPlanForm,
      patientId: Number(treatmentPlanForm.patientId),
      doctorId: Number(treatmentPlanForm.doctorId),
      packageId: treatmentPlanForm.packageId ? Number(treatmentPlanForm.packageId) : null,
      treatmentDurationWeeks: treatmentPlanForm.treatmentDurationWeeks ? Number(treatmentPlanForm.treatmentDurationWeeks) : null,
      recommendedTherapies: treatmentPlanForm.recommendedTherapies
        .split(",")
        .map((item) => item.trim())
        .filter(Boolean)
    };

    await submitAction(
      () =>
        editingTreatmentPlanId
          ? client.put(`/doctors/treatment-plans/${editingTreatmentPlanId}`, payload)
          : client.post("/doctors/treatment-plans", payload),
      editingTreatmentPlanId ? "Treatment plan updated successfully" : "Treatment plan assigned successfully"
    );
    setEditingTreatmentPlanId(null);
    setTreatmentPlanForm(emptyTreatmentPlanForm);
  }

  async function handleSessionSubmit(event) {
    event.preventDefault();
    await submitAction(
      () =>
        client.post("/sessions", {
          ...sessionForm,
          appointmentId: Number(sessionForm.appointmentId),
          patientComfortRating: Number(sessionForm.patientComfortRating),
          status: "Completed"
        }),
      "Therapy session recorded successfully"
    );
    setSessionForm(emptySessionForm);
  }

  async function handleInventoryUsageSubmit(event) {
    event.preventDefault();
    await submitAction(
      () =>
        client.post("/sessions/inventory-usage", {
          therapySessionId: Number(inventoryUsageForm.therapySessionId),
          inventoryItemId: Number(inventoryUsageForm.inventoryItemId),
          quantityUsed: Number(inventoryUsageForm.quantityUsed)
        }),
      "Inventory usage posted successfully"
    );
    setInventoryUsageForm(emptyInventoryUsageForm);
  }

  async function handleBillSubmit(event) {
    event.preventDefault();
    await submitAction(
      () =>
        client.post("/billing/bills/generate", {
          appointmentId: Number(billForm.appointmentId),
          discountAmount: Number(billForm.discountAmount || 0),
          previousPendingAmount: Number(billForm.previousPendingAmount || 0),
          paymentTerms: billForm.paymentTerms
        }),
      "Bill generated successfully"
    );
    setBillForm(emptyBillForm);
  }

  async function handlePaymentSubmit(event) {
    event.preventDefault();
    await submitAction(
      () =>
        client.post("/billing/payments", {
          billId: Number(paymentForm.billId),
          amountPaid: Number(paymentForm.amountPaid),
          paymentMode: paymentForm.paymentMode,
          referenceNumber: paymentForm.referenceNumber,
          notes: paymentForm.notes
        }),
      "Payment recorded successfully"
    );
    setPaymentForm(emptyPaymentForm);
  }

  if (loading) {
    return (
      <main className="mx-auto max-w-7xl px-6 py-10">
        <section className="rounded-[2rem] bg-brand-ink p-8 text-white shadow-glow">
          <p className="text-sm uppercase tracking-[0.3em] text-brand-sand">{user?.role || "user"} dashboard</p>
          <h1 className="mt-3 font-display text-4xl">Loading clinic workspace...</h1>
          <p className="mt-3 max-w-3xl text-brand-sand">Pulling the latest operational data from the server.</p>
        </section>
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-7xl px-6 py-10">
      <section className="mb-8 rounded-[2rem] bg-brand-ink p-8 text-white shadow-glow">
        <p className="text-sm uppercase tracking-[0.3em] text-brand-sand">{user?.role || "user"} dashboard</p>
        <h1 className="mt-3 font-display text-4xl">{user?.full_name || user?.email}</h1>
        <p className="mt-3 max-w-3xl text-brand-sand">{roleMessages[user?.role] || roleMessages.admin}</p>
        {message.text ? (
          <p
            className={`mt-4 rounded-2xl px-4 py-3 text-sm ${
              message.type === "error" ? "bg-red-500/15 text-red-100" : "bg-white/10 text-brand-sand"
            }`}
          >
            {message.text}
          </p>
        ) : null}
      </section>

      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-4">
        {summaryCards.map((card) => (
          <MetricCard key={card.label} label={card.label} value={card.value} accent={card.accent} />
        ))}
      </section>

      {user?.role === "patient" ? (
        <>
          <section className="mt-8 grid gap-6 xl:grid-cols-2">
            <DataTable
              title="My Appointments"
              columns={[
                { key: "therapy_name", label: "Therapy" },
                { key: "appointment_date", label: "Date" },
                { key: "visit_type", label: "Visit type" },
                { key: "status", label: "Status" }
              ]}
              rows={appointments.map((row) => ({ ...row, appointment_date: fmtDate(row.appointment_date) }))}
              filterKey="status"
              searchPlaceholder="Search my appointments"
            />
            <DataTable
              title="My Bills"
              columns={[
                { key: "invoice_number", label: "Invoice" },
                { key: "bill_date", label: "Bill date" },
                { key: "net_amount", label: "Net amount" },
                { key: "pending_amount", label: "Pending" },
                { key: "status", label: "Status" }
              ]}
              rows={bills}
              filterKey="status"
              searchPlaceholder="Search my bills"
            />
          </section>
          <section className="mt-6">
            <DataTable
              title="My Treatment Timeline"
              columns={[
                { key: "diagnosis", label: "Diagnosis" },
                { key: "therapy_name", label: "Therapy" },
                { key: "appointment_status", label: "Appointment" },
                { key: "session_status", label: "Session" }
              ]}
              rows={treatmentPlans}
              filterKey="treatment_status"
              searchPlaceholder="Search my treatment records"
            />
          </section>
        </>
      ) : (
        <>
          {(user?.role === "admin" || user?.role === "receptionist") && (
            <section className="mt-8 grid gap-6 xl:grid-cols-2">
              <ActionCard title={editingPatientId ? "Update patient record" : "Register new patient"} description="Capture and maintain patient information with validation and audit tracking.">
                <form className="grid gap-4 md:grid-cols-2" onSubmit={handlePatientSubmit}>
                  <FormField label="First name" value={patientForm.firstName} onChange={(e) => setPatientForm({ ...patientForm, firstName: e.target.value })} />
                  <FormField label="Last name" value={patientForm.lastName} onChange={(e) => setPatientForm({ ...patientForm, lastName: e.target.value })} />
                  <FormField label="Date of birth" type="date" value={patientForm.dateOfBirth} onChange={(e) => setPatientForm({ ...patientForm, dateOfBirth: e.target.value })} />
                  <SelectField label="Gender" value={patientForm.gender} onChange={(e) => setPatientForm({ ...patientForm, gender: e.target.value })}>
                    <option>Female</option>
                    <option>Male</option>
                    <option>Other</option>
                  </SelectField>
                  <FormField label="Email" value={patientForm.email} onChange={(e) => setPatientForm({ ...patientForm, email: e.target.value })} />
                  <FormField label="Phone" value={patientForm.primaryPhone} onChange={(e) => setPatientForm({ ...patientForm, primaryPhone: e.target.value })} />
                  <FormField label="City" value={patientForm.city} onChange={(e) => setPatientForm({ ...patientForm, city: e.target.value })} />
                  <FormField label="State" value={patientForm.state} onChange={(e) => setPatientForm({ ...patientForm, state: e.target.value })} />
                  <SelectField label="Constitution" value={patientForm.constitutionType} onChange={(e) => setPatientForm({ ...patientForm, constitutionType: e.target.value })}>
                    <option>Vata</option>
                    <option>Pitta</option>
                    <option>Kapha</option>
                    <option>Vata-Pitta</option>
                    <option>Pitta-Kapha</option>
                    <option>Vata-Kapha</option>
                    <option>Tri-dosha</option>
                  </SelectField>
                  <SelectField label="Lifecycle stage" value={patientForm.lifecycleStage} onChange={(e) => setPatientForm({ ...patientForm, lifecycleStage: e.target.value })}>
                    <option>Intake</option>
                    <option>Treatment</option>
                    <option>Follow-up</option>
                    <option>Discharged</option>
                  </SelectField>
                  <TextAreaField label="Allergies" value={patientForm.allergies} onChange={(e) => setPatientForm({ ...patientForm, allergies: e.target.value })} />
                  <TextAreaField label="Medical history" value={patientForm.medicalHistory} onChange={(e) => setPatientForm({ ...patientForm, medicalHistory: e.target.value })} />
                  <div className="md:col-span-2 flex gap-3">
                    <button disabled={busy} className="rounded-full bg-brand-forest px-5 py-3 text-white">
                      {editingPatientId ? "Save Changes" : "Create Patient"}
                    </button>
                    {editingPatientId ? (
                      <button type="button" className="rounded-full border px-5 py-3" onClick={() => { setEditingPatientId(null); setPatientForm(emptyPatientForm); }}>
                        Cancel
                      </button>
                    ) : null}
                  </div>
                </form>
              </ActionCard>

              <ActionCard title="Manage appointments" description="Schedule bookings and keep same-day statuses updated from the reception workflow.">
                <form className="grid gap-4 md:grid-cols-2" onSubmit={handleAppointmentSubmit}>
                  <SelectField label="Patient" value={appointmentForm.patientId} onChange={(e) => setAppointmentForm({ ...appointmentForm, patientId: e.target.value })}>
                    <option value="">Select patient</option>
                    {patientOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </SelectField>
                  <SelectField label="Therapy" value={appointmentForm.therapyId} onChange={(e) => setAppointmentForm({ ...appointmentForm, therapyId: e.target.value })}>
                    <option value="">Select therapy</option>
                    {therapies.map((therapy) => (
                      <option key={therapy.id} value={therapy.id}>
                        {therapy.name}
                      </option>
                    ))}
                  </SelectField>
                  <FormField label="Appointment date" type="datetime-local" value={appointmentForm.appointmentDate} onChange={(e) => setAppointmentForm({ ...appointmentForm, appointmentDate: e.target.value })} />
                  <FormField label="Therapist ID" value={appointmentForm.therapistId} onChange={(e) => setAppointmentForm({ ...appointmentForm, therapistId: e.target.value })} />
                  <FormField label="Visit type" value={appointmentForm.visitType} onChange={(e) => setAppointmentForm({ ...appointmentForm, visitType: e.target.value })} />
                  <FormField label="Buffer minutes" type="number" value={appointmentForm.bufferMinutes} onChange={(e) => setAppointmentForm({ ...appointmentForm, bufferMinutes: e.target.value })} />
                  <div className="md:col-span-2">
                    <TextAreaField label="Notes" value={appointmentForm.notes} onChange={(e) => setAppointmentForm({ ...appointmentForm, notes: e.target.value })} />
                  </div>
                  <div className="md:col-span-2">
                    <button disabled={busy} className="rounded-full bg-brand-clay px-5 py-3 text-white">Create Appointment</button>
                  </div>
                </form>
              </ActionCard>
            </section>
          )}

          {(user?.role === "admin" || user?.role === "doctor") && (
            <section className="mt-6">
              <ActionCard title={editingTreatmentPlanId ? "Update treatment plan" : "Assign treatment plan"} description="Doctors can prescribe structured care plans and change them as the patient improves.">
                <form className="grid gap-4 md:grid-cols-3" onSubmit={handleTreatmentPlanSubmit}>
                  <SelectField label="Patient" value={treatmentPlanForm.patientId} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, patientId: e.target.value })}>
                    <option value="">Select patient</option>
                    {patientOptions.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </SelectField>
                  <FormField label="Doctor ID" value={treatmentPlanForm.doctorId} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, doctorId: e.target.value })} />
                  <SelectField label="Package" value={treatmentPlanForm.packageId} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, packageId: e.target.value })}>
                    <option value="">Select package</option>
                    {packages.map((pkg) => (
                      <option key={pkg.id} value={pkg.id}>
                        {pkg.name}
                      </option>
                    ))}
                  </SelectField>
                  <FormField label="Diagnosis" value={treatmentPlanForm.diagnosis} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, diagnosis: e.target.value })} />
                  <FormField label="Recommended therapies" value={treatmentPlanForm.recommendedTherapies} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, recommendedTherapies: e.target.value })} placeholder="Abhyanga, Shirodhara" />
                  <SelectField label="Status" value={treatmentPlanForm.status} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, status: e.target.value })}>
                    <option>Draft</option>
                    <option>Active</option>
                    <option>Completed</option>
                    <option>Cancelled</option>
                  </SelectField>
                  <FormField label="Start date" type="date" value={treatmentPlanForm.startDate} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, startDate: e.target.value })} />
                  <FormField label="End date" type="date" value={treatmentPlanForm.endDate} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, endDate: e.target.value })} />
                  <FormField label="Duration (weeks)" type="number" value={treatmentPlanForm.treatmentDurationWeeks} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, treatmentDurationWeeks: e.target.value })} />
                  <div className="md:col-span-3">
                    <TextAreaField label="Condition details" value={treatmentPlanForm.conditionDetails} onChange={(e) => setTreatmentPlanForm({ ...treatmentPlanForm, conditionDetails: e.target.value })} />
                  </div>
                  <div className="md:col-span-3">
                    <button disabled={busy} className="rounded-full bg-brand-forest px-5 py-3 text-white">
                      {editingTreatmentPlanId ? "Save Treatment Plan" : "Assign Treatment Plan"}
                    </button>
                  </div>
                </form>
              </ActionCard>
            </section>
          )}

          {(user?.role === "admin" || user?.role === "therapist") && (
            <section className="mt-6 grid gap-6 xl:grid-cols-2">
              <ActionCard title="Record therapy session" description="Complete the clinical session and update patient comfort, notes, and recommendations.">
                <form className="grid gap-4 md:grid-cols-2" onSubmit={handleSessionSubmit}>
                  <FormField label="Appointment ID" value={sessionForm.appointmentId} onChange={(e) => setSessionForm({ ...sessionForm, appointmentId: e.target.value })} />
                  <FormField label="Session date" type="datetime-local" value={sessionForm.sessionDate} onChange={(e) => setSessionForm({ ...sessionForm, sessionDate: e.target.value })} />
                  <FormField label="Comfort rating" type="number" min="1" max="5" value={sessionForm.patientComfortRating} onChange={(e) => setSessionForm({ ...sessionForm, patientComfortRating: e.target.value })} />
                  <FormField label="Recommendations" value={sessionForm.recommendations} onChange={(e) => setSessionForm({ ...sessionForm, recommendations: e.target.value })} />
                  <div className="md:col-span-2">
                    <TextAreaField label="Observations" value={sessionForm.observations} onChange={(e) => setSessionForm({ ...sessionForm, observations: e.target.value })} />
                  </div>
                  <div className="md:col-span-2">
                    <TextAreaField label="Therapist notes" value={sessionForm.therapistNotes} onChange={(e) => setSessionForm({ ...sessionForm, therapistNotes: e.target.value })} />
                  </div>
                  <div className="md:col-span-2">
                    <button disabled={busy} className="rounded-full bg-brand-clay px-5 py-3 text-white">Save Session</button>
                  </div>
                </form>
              </ActionCard>

              <ActionCard title="Post inventory usage" description="Deduct oils and medicines against a therapy session with immediate stock updates.">
                <form className="grid gap-4 md:grid-cols-2" onSubmit={handleInventoryUsageSubmit}>
                  <FormField label="Therapy session ID" value={inventoryUsageForm.therapySessionId} onChange={(e) => setInventoryUsageForm({ ...inventoryUsageForm, therapySessionId: e.target.value })} />
                  <SelectField label="Inventory item" value={inventoryUsageForm.inventoryItemId} onChange={(e) => setInventoryUsageForm({ ...inventoryUsageForm, inventoryItemId: e.target.value })}>
                    <option value="">Select item</option>
                    {inventory.map((item) => (
                      <option key={item.id} value={item.id}>
                        {item.item_name}
                      </option>
                    ))}
                  </SelectField>
                  <FormField label="Quantity used" type="number" step="0.01" value={inventoryUsageForm.quantityUsed} onChange={(e) => setInventoryUsageForm({ ...inventoryUsageForm, quantityUsed: e.target.value })} />
                  <div className="md:col-span-2">
                    <button disabled={busy} className="rounded-full bg-brand-forest px-5 py-3 text-white">Log Usage</button>
                  </div>
                </form>
              </ActionCard>
            </section>
          )}

          {(user?.role === "admin" || user?.role === "receptionist") && (
            <section className="mt-6 grid gap-6 xl:grid-cols-2">
              <ActionCard title="Generate bill" description="Create a bill from a finished appointment using the billing procedure layer.">
                <form className="grid gap-4 md:grid-cols-2" onSubmit={handleBillSubmit}>
                  <FormField label="Appointment ID" value={billForm.appointmentId} onChange={(e) => setBillForm({ ...billForm, appointmentId: e.target.value })} />
                  <FormField label="Discount amount" type="number" value={billForm.discountAmount} onChange={(e) => setBillForm({ ...billForm, discountAmount: e.target.value })} />
                  <FormField label="Previous pending" type="number" value={billForm.previousPendingAmount} onChange={(e) => setBillForm({ ...billForm, previousPendingAmount: e.target.value })} />
                  <FormField label="Payment terms" value={billForm.paymentTerms} onChange={(e) => setBillForm({ ...billForm, paymentTerms: e.target.value })} />
                  <div className="md:col-span-2">
                    <button disabled={busy} className="rounded-full bg-brand-clay px-5 py-3 text-white">Generate Bill</button>
                  </div>
                </form>
              </ActionCard>

              <ActionCard title="Record payment" description="Post collections and update receivables immediately from the reception desk.">
                <form className="grid gap-4 md:grid-cols-2" onSubmit={handlePaymentSubmit}>
                  <FormField label="Bill ID" value={paymentForm.billId} onChange={(e) => setPaymentForm({ ...paymentForm, billId: e.target.value })} />
                  <FormField label="Amount paid" type="number" value={paymentForm.amountPaid} onChange={(e) => setPaymentForm({ ...paymentForm, amountPaid: e.target.value })} />
                  <SelectField label="Payment mode" value={paymentForm.paymentMode} onChange={(e) => setPaymentForm({ ...paymentForm, paymentMode: e.target.value })}>
                    <option>Cash</option>
                    <option>Card</option>
                    <option>UPI</option>
                    <option>Bank Transfer</option>
                    <option>Cheque</option>
                    <option>Insurance</option>
                  </SelectField>
                  <FormField label="Reference number" value={paymentForm.referenceNumber} onChange={(e) => setPaymentForm({ ...paymentForm, referenceNumber: e.target.value })} />
                  <div className="md:col-span-2">
                    <TextAreaField label="Notes" value={paymentForm.notes} onChange={(e) => setPaymentForm({ ...paymentForm, notes: e.target.value })} />
                  </div>
                  <div className="md:col-span-2">
                    <button disabled={busy} className="rounded-full bg-brand-forest px-5 py-3 text-white">Record Payment</button>
                  </div>
                </form>
              </ActionCard>
            </section>
          )}

          <section className="mt-8 grid gap-6 xl:grid-cols-2">
            {(user?.role === "admin" || user?.role === "receptionist") && (
              <DataTable
                title="Patient Registry"
                columns={[
                  { key: "full_name", label: "Patient" },
                  { key: "segment", label: "Segment" },
                  { key: "lifecycle_stage", label: "Stage" },
                  { key: "city", label: "City" }
                ]}
                rows={patients}
                actions={(row) => [{ label: "Edit", onClick: () => beginEditPatient(row) }]}
                filterKey="lifecycle_stage"
                searchPlaceholder="Search patients"
              />
            )}
            <DataTable
              title="Appointment Queue"
              columns={[
                { key: "patient_name", label: "Patient" },
                { key: "therapy_name", label: "Therapy" },
                { key: "appointment_date", label: "Date" },
                { key: "status", label: "Status" }
              ]}
              rows={appointments.map((row) => ({ ...row, appointment_date: fmtDate(row.appointment_date) }))}
              actions={appointmentActions}
              filterKey="status"
              searchPlaceholder="Search appointments"
            />
          </section>

          <section className="mt-6 grid gap-6 xl:grid-cols-2">
            {(user?.role === "admin" || user?.role === "doctor") && (
              <DataTable
                title="Treatment Plans"
                columns={[
                  { key: "patient_name", label: "Patient" },
                  { key: "doctor_name", label: "Doctor" },
                  { key: "diagnosis", label: "Diagnosis" },
                  { key: "status", label: "Status" }
                ]}
                rows={treatmentPlans}
                actions={(row) => [{ label: "Edit", onClick: () => beginEditTreatmentPlan(row) }]}
                filterKey="status"
                searchPlaceholder="Search treatment plans"
              />
            )}
            {(user?.role === "admin" || user?.role === "receptionist" || user?.role === "doctor") && (
              <DataTable
                title="Billing Overview"
                columns={[
                  { key: "invoice_number", label: "Invoice" },
                  { key: "patient_name", label: "Patient" },
                  { key: "net_amount", label: "Net" },
                  { key: "pending_amount", label: "Pending" },
                  { key: "status", label: "Status" }
                ]}
                rows={bills}
                filterKey="status"
                searchPlaceholder="Search bills"
              />
            )}
          </section>

          {(user?.role === "admin" || user?.role === "therapist" || user?.role === "doctor") && (
            <section className="mt-6 grid gap-6 xl:grid-cols-2">
              <DataTable
                title="Therapy Sessions"
                columns={[
                  { key: "patient_name", label: "Patient" },
                  { key: "therapy_name", label: "Therapy" },
                  { key: "session_date", label: "Session date" },
                  { key: "status", label: "Status" }
                ]}
                rows={sessions.map((row) => ({ ...row, session_date: fmtDate(row.session_date || row.appointment_date) }))}
                filterKey="status"
                searchPlaceholder="Search therapy sessions"
              />
              <DataTable
                title="Inventory Status"
                columns={[
                  { key: "item_name", label: "Item" },
                  { key: "item_type", label: "Type" },
                  { key: "quantity_in_stock", label: "Stock" },
                  { key: "stock_status", label: "Status" }
                ]}
                rows={inventory}
                filterKey="stock_status"
                searchPlaceholder="Search inventory"
              />
            </section>
          )}

          {user?.role === "admin" && (
            <section className="mt-6">
              <DataTable
                title="Recent Activity Logs"
                columns={[
                  { key: "full_name", label: "User" },
                  { key: "action", label: "Action" },
                  { key: "entity_type", label: "Entity" },
                  { key: "created_at", label: "Time" }
                ]}
                rows={activityLogs.map((row) => ({ ...row, created_at: fmtDate(row.created_at), full_name: row.full_name || "System" }))}
                searchPlaceholder="Search activity"
                filterKey="entity_type"
              />
            </section>
          )}
        </>
      )}
    </main>
  );
}
