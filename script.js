// SDMS Interactive Landing Page Logic
document.addEventListener('DOMContentLoaded', () => {
  // Navbar scroll background shift
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });

  // Portal Switcher Tabs
  const tabBtns = document.querySelectorAll('.tab-btn');
  const portalTitle = document.getElementById('portal-title');
  const portalDesc = document.getElementById('portal-desc');
  const portalFeatures = document.getElementById('portal-features');
  const previewBadge = document.getElementById('preview-badge');
  const previewCaseId = document.getElementById('preview-case-id');
  const previewStatusText = document.getElementById('preview-status-text');
  const previewBody = document.getElementById('preview-body');

  const portalData = {
    student: {
      title: "Student Portal: Transparency & Due Process",
      desc: "Empowering students with clear visibility into reported incidents, scheduled committee hearings, and seamless 1-click appeal channels.",
      features: [
        "Confidential incident reporting & witness statement submission",
        "Real-time notifications for hearing venue, time, and committee agenda",
        "Direct access to ruling decisions and rehabilitation requirement steps",
        "Streamlined 1-click appeal submission with status tracking"
      ],
      badgeClass: "scheduled",
      badgeText: "HEARING SCHEDULED",
      caseId: "SDMS-2026-089",
      statusText: "Scheduled for Aug 12, 2026 at Dean's Office Boardroom",
      bodyHtml: `
        <div style="background: rgba(255,255,255,0.03); padding: 12px; border-radius: 8px; margin-bottom: 12px;">
          <div style="font-size: 11px; color: #94A3B8;">ALLEGED INCIDENT</div>
          <div style="font-size: 13px; font-weight: 600; color: #F8FAFC;">Library Noise & Disruption Policy</div>
        </div>
        <div style="font-size: 12px; color: #10B981; font-weight: 600; display: flex; align-items: center; gap: 6px;">
          <i class="ri-checkbox-circle-line"></i> Hearing notice dispatched to student email & portal
        </div>
      `
    },
    staff: {
      title: "Staff & Committee Portal: Enforced Workflow & Hearing Governance",
      desc: "Designed for disciplinary officers to manage queues, schedule hearings with single-record persistence, and record rulings safely.",
      features: [
        "Queue-based incident investigation & staff assignment dashboard",
        "Single-record hearing schedule persistence (no duplicate rows)",
        "Enforced sequential workflow: Sanctions unlock ONLY after hearing date",
        "Integrated committee meeting notes and official ruling generation"
      ],
      badgeClass: "sanction",
      badgeText: "SANCTION RECORDED",
      caseId: "SDMS-2026-074",
      statusText: "Formal Written Warning + 5 hrs Community Service",
      bodyHtml: `
        <div style="background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.3); padding: 12px; border-radius: 8px; margin-bottom: 12px;">
          <div style="font-size: 11px; color: #F87171; font-weight: 700;">DECISION & RULING</div>
          <div style="font-size: 13px; color: #F8FAFC;">Hearing Concluded on Aug 01, 2026. Ruling ratified by committee.</div>
        </div>
        <div style="font-size: 12px; color: #94A3B8;">
          Workflow Status: <span style="color: #10B981; font-weight: 600;">Hearing Complete → Sanction Issued</span>
        </div>
      `
    },
    admin: {
      title: "Administrator Portal: Institutional Oversight & Appeals",
      desc: "Provides university executive leadership with analytical dashboards, appeal review approvals, and institutional compliance audit trails.",
      features: [
        "Executive analytics on incident categories, resolution speed & trends",
        "Appeals board review panel with Approve / Deny / Remand authority",
        "Cross-departmental staff workload & case assignment controls",
        "Complete institutional audit logs & policy compliance export"
      ],
      badgeClass: "appealed",
      badgeText: "UNDER APPEAL REVIEW",
      caseId: "SDMS-2026-052",
      statusText: "Appeal Filed by Student - Pending Board Review",
      bodyHtml: `
        <div style="background: rgba(245,158,11,0.1); border: 1px solid rgba(245,158,11,0.3); padding: 12px; border-radius: 8px; margin-bottom: 12px;">
          <div style="font-size: 11px; color: #FBBF24; font-weight: 700;">APPEAL GROUNDS</div>
          <div style="font-size: 13px; color: #F8FAFC;">New mitigating medical evidence submitted for committee review.</div>
        </div>
        <div style="display: flex; gap: 8px;">
          <button style="flex: 1; padding: 8px; border-radius: 6px; background: #10B981; color: white; border: none; font-size: 12px; font-weight: 600; cursor: pointer;">Approve Appeal</button>
          <button style="flex: 1; padding: 8px; border-radius: 6px; background: #EF4444; color: white; border: none; font-size: 12px; font-weight: 600; cursor: pointer;">Maintain Ruling</button>
        </div>
      `
    }
  };

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      tabBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const role = btn.dataset.role;
      const data = portalData[role];

      portalTitle.textContent = data.title;
      portalDesc.textContent = data.desc;

      portalFeatures.innerHTML = data.features
        .map(f => `<li><i class="ri-check-line"></i> ${f}</li>`)
        .join('');

      previewBadge.className = `preview-badge ${data.badgeClass}`;
      previewBadge.textContent = data.badgeText;
      previewCaseId.textContent = data.caseId;
      previewStatusText.textContent = data.statusText;
      previewBody.innerHTML = data.bodyHtml;
    });
  });

  // Interactive Live Sandbox Simulator
  const demoDateInput = document.getElementById('demo-date');
  const demoStatusSelect = document.getElementById('demo-status');
  const sandboxBanner = document.getElementById('sandbox-banner');
  const sandboxIcon = document.getElementById('sandbox-icon');
  const sandboxTitle = document.getElementById('sandbox-title');
  const sandboxMsg = document.getElementById('sandbox-msg');

  // Set default demo date to tomorrow
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  demoDateInput.value = tomorrow.toISOString().split('T')[0];

  function updateSandbox() {
    const selectedDateStr = demoDateInput.value;
    if (!selectedDateStr) return;

    const selectedDate = new Date(selectedDateStr);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    selectedDate.setHours(0, 0, 0, 0);

    const hasHearing = demoStatusSelect.value !== 'no_hearing';
    const isPastOrToday = selectedDate <= today;

    if (!hasHearing) {
      sandboxBanner.className = 'status-banner locked';
      sandboxIcon.className = 'ri-lock-line';
      sandboxTitle.textContent = 'Sanction Module Locked';
      sandboxMsg.textContent = 'A disciplinary hearing must be scheduled first before sanctions or rulings can be recorded.';
    } else if (!isPastOrToday) {
      sandboxBanner.className = 'status-banner locked';
      sandboxIcon.className = 'ri-calendar-event-line';
      sandboxTitle.textContent = `Hearing Pending (${selectedDateStr})`;
      sandboxMsg.textContent = `The hearing is scheduled for ${selectedDateStr}. Sanctions & rulings are locked until the hearing date arrives.`;
    } else {
      sandboxBanner.className = 'status-banner unlocked';
      sandboxIcon.className = 'ri-shield-check-line';
      sandboxTitle.textContent = 'Sanction Module Unlocked & Ready!';
      sandboxMsg.textContent = 'Hearing date reached! Staff can now enter committee ruling, formal warning, suspension terms, or probation details.';
    }
  }

  demoDateInput.addEventListener('change', updateSandbox);
  demoStatusSelect.addEventListener('change', updateSandbox);
  updateSandbox();

  // How To Use Guide Role Switcher
  const guideRoleBtns = document.querySelectorAll('.guide-role-btn');
  const guideGrid = document.getElementById('guide-grid');

  const guideData = {
    student: [
      {
        step: '1',
        title: 'Log In & View Record',
        desc: 'Access your account using your Student ID. View your active disciplinary status and historical case log in real-time.',
        tip: 'Tip: Your status remains "Clean Record" if no active cases exist.'
      },
      {
        step: '2',
        title: 'Report Incident / Statement',
        desc: 'Submit a confidential incident report or witness statement with category tags (academic dishonesty, conduct, property damage).',
        tip: 'Tip: Evidence description helps committee officers assess priority.'
      },
      {
        step: '3',
        title: 'Hearings & Appeal Options',
        desc: 'Receive hearing date and venue details. Once ruling is issued, file a 1-click appeal with supporting evidence if eligible.',
        tip: 'Tip: Appeals must be submitted within the university policy timeframe.'
      }
    ],
    staff: [
      {
        step: '1',
        title: 'Inspect Assigned Queue',
        desc: 'Review cases assigned to your queue. Check student ID, incident description, category, and assigned priority.',
        tip: 'Tip: Filter cases by priority (Urgent, High, Medium, Low).'
      },
      {
        step: '2',
        title: 'Schedule Hearing Date',
        desc: 'Select hearing date & venue (e.g. Dean of Students Office). The system updates schedule state cleanly without duplicate rows.',
        tip: 'Tip: Hearing schedules dispatch automated notifications.'
      },
      {
        step: '3',
        title: 'Record Gated Sanction Ruling',
        desc: 'The Sanction Module automatically unlocks on or after the scheduled hearing date. Record formal warnings, probation, or suspension.',
        tip: 'Tip: Sanctions are locked before the hearing date to guarantee due process.'
      }
    ],
    admin: [
      {
        step: '1',
        title: 'Institutional Dashboard Overview',
        desc: 'Monitor university-wide case counts, pending hearings, active sanctions, and department resolution speeds.',
        tip: 'Tip: Use search bar to filter by student ID or incident category.'
      },
      {
        step: '2',
        title: 'Appeals Review Panel',
        desc: 'Inspect student appeal submissions. Review new mitigating evidence or procedural grounds before issuing final decision.',
        tip: 'Tip: Board decisions update case status to Closed or Remanded.'
      },
      {
        step: '3',
        title: 'Staff Workload & Audit Control',
        desc: 'Reassign cases among committee staff officers and export institutional policy compliance reports for governance.',
        tip: 'Tip: All actions generate timestamped institutional audit logs.'
      }
    ]
  };

  guideRoleBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      guideRoleBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const role = btn.dataset.guideRole;
      const steps = guideData[role];

      guideGrid.innerHTML = steps.map(s => `
        <div class="guide-step-card">
          <div class="guide-step-badge">${s.step}</div>
          <h3 class="guide-step-title">${s.title}</h3>
          <p class="guide-step-desc">${s.desc}</p>
          <div class="guide-tip-box">${s.tip}</div>
        </div>
      `).join('');
    });
  });

  // FAQ Accordion Toggle
  const faqQuestions = document.querySelectorAll('.faq-question');
  faqQuestions.forEach(q => {
    q.addEventListener('click', () => {
      const item = q.parentElement;
      const isActive = item.classList.contains('active');
      document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('active'));
      if (!isActive) {
        item.classList.add('active');
      }
    });
  });
});

