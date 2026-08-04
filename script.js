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
      title: "Student Portal: Case Progress Tracking & Evidence Attachments",
      desc: "Empowering students with real-time case progression tracking, photo & video evidence upload channels, scheduled hearing notices, and 1-click appeal submissions.",
      features: [
        "Visual 4-Stage Case Progress Bar (Intake → Hearing → Ruling → Resolved)",
        "Dedicated Photo & Video evidence attachment portal (JPEG, PNG, MP4, MOV)",
        "Real-time hearing venue notices & committee agenda dispatch",
        "Streamlined 1-click appeal submission with new supporting evidence"
      ],
      badgeClass: "scheduled",
      badgeText: "HEARING SCHEDULED (STAGE 2)",
      caseId: "SDMS-2026-089",
      statusText: "Scheduled for Aug 12, 2026 at Dean's Office Boardroom",
      bodyHtml: `
        <!-- Student Case Progress Bar Component -->
        <div class="case-progress-wrapper">
          <div class="case-progress-header">
            <div class="case-progress-title">
              <i class="ri-line-chart-line"></i> Case Progression Bar
            </div>
            <span class="case-progress-badge">Stage 2 of 4 • 50%</span>
          </div>
          <div class="case-progress-track">
            <div class="case-progress-fill" style="width: 50%;"></div>
          </div>
          <div class="case-steps-row">
            <div class="case-step-item completed">
              <div class="case-step-node"><i class="ri-check-line"></i></div>
              <span class="case-step-label">1. Intake</span>
            </div>
            <div class="case-step-item active">
              <div class="case-step-node">2</div>
              <span class="case-step-label">2. Hearing</span>
            </div>
            <div class="case-step-item">
              <div class="case-step-node">3</div>
              <span class="case-step-label">3. Ruling</span>
            </div>
            <div class="case-step-item">
              <div class="case-step-node">4</div>
              <span class="case-step-label">4. Resolved</span>
            </div>
          </div>
        </div>

        <div style="background: rgba(255,255,255,0.03); padding: 12px; border-radius: 8px; margin-bottom: 12px;">
          <div style="font-size: 11px; color: #94A3B8;">ALLEGED INCIDENT</div>
          <div style="font-size: 13px; font-weight: 600; color: #F8FAFC;">Library Noise & Disruption Policy</div>
        </div>

        <!-- Photo & Video Evidence Gallery -->
        <div class="evidence-section">
          <div class="evidence-title"><i class="ri-attachment-line"></i> Case Evidence (Photos & Videos)</div>
          <div class="evidence-grid">
            <div class="evidence-chip video" onclick="openEvidenceModal('CCTV_Hallway_Footage.mp4', 'video', '18.4 MB', 'Timestamped hallway footage showing entry/exit.')">
              <i class="ri-video-fill"></i> CCTV_Footage.mp4
            </div>
            <div class="evidence-chip photo" onclick="openEvidenceModal('Library_Desk_Photo.jpg', 'photo', '2.4 MB', 'Photo of library seating area.')">
              <i class="ri-image-fill"></i> Desk_Photo.jpg
            </div>
          </div>
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
        "Integrated committee meeting notes and evidence review panel"
      ],
      badgeClass: "sanction",
      badgeText: "SANCTION RECORDED (STAGE 3)",
      caseId: "SDMS-2026-074",
      statusText: "Formal Written Warning + 5 hrs Community Service",
      bodyHtml: `
        <!-- Staff Case Progress Bar Component -->
        <div class="case-progress-wrapper">
          <div class="case-progress-header">
            <div class="case-progress-title">
              <i class="ri-line-chart-line"></i> Case Progression Bar
            </div>
            <span class="case-progress-badge" style="color: #10B981; border-color: rgba(16,185,129,0.3); background: rgba(16,185,129,0.15);">Stage 3 of 4 • 75%</span>
          </div>
          <div class="case-progress-track">
            <div class="case-progress-fill" style="width: 75%; background: linear-gradient(90deg, #10B981, #059669);"></div>
          </div>
          <div class="case-steps-row">
            <div class="case-step-item completed">
              <div class="case-step-node"><i class="ri-check-line"></i></div>
              <span class="case-step-label">1. Intake</span>
            </div>
            <div class="case-step-item completed">
              <div class="case-step-node"><i class="ri-check-line"></i></div>
              <span class="case-step-label">2. Hearing</span>
            </div>
            <div class="case-step-item active">
              <div class="case-step-node">3</div>
              <span class="case-step-label">3. Ruling</span>
            </div>
            <div class="case-step-item">
              <div class="case-step-node">4</div>
              <span class="case-step-label">4. Resolved</span>
            </div>
          </div>
        </div>

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
      title: "Administrator Portal: Institutional Oversight & Appeals Board",
      desc: "Provides university executive leadership with analytical dashboards, appeal review approvals, and institutional compliance audit trails.",
      features: [
        "Executive analytics on incident categories, resolution speed & trends",
        "Appeals board review panel with Approve / Deny / Remand authority",
        "Cross-departmental staff workload & case assignment controls",
        "Complete institutional audit logs & evidence file inspection"
      ],
      badgeClass: "appealed",
      badgeText: "UNDER APPEAL REVIEW (STAGE 3.5)",
      caseId: "SDMS-2026-052",
      statusText: "Appeal Filed by Student - Pending Board Review",
      bodyHtml: `
        <!-- Admin Case Progress Bar Component -->
        <div class="case-progress-wrapper">
          <div class="case-progress-header">
            <div class="case-progress-title">
              <i class="ri-line-chart-line"></i> Case Progression Bar
            </div>
            <span class="case-progress-badge" style="color: #FBBF24; border-color: rgba(245,158,11,0.3); background: rgba(245,158,11,0.15);">Stage 3 of 4 • 85%</span>
          </div>
          <div class="case-progress-track">
            <div class="case-progress-fill" style="width: 85%; background: linear-gradient(90deg, #F59E0B, #D97706);"></div>
          </div>
          <div class="case-steps-row">
            <div class="case-step-item completed">
              <div class="case-step-node"><i class="ri-check-line"></i></div>
              <span class="case-step-label">1. Intake</span>
            </div>
            <div class="case-step-item completed">
              <div class="case-step-node"><i class="ri-check-line"></i></div>
              <span class="case-step-label">2. Hearing</span>
            </div>
            <div class="case-step-item completed">
              <div class="case-step-node"><i class="ri-check-line"></i></div>
              <span class="case-step-label">3. Ruling</span>
            </div>
            <div class="case-step-item active">
              <div class="case-step-node">4</div>
              <span class="case-step-label">4. Appeal Review</span>
            </div>
          </div>
        </div>

        <div style="background: rgba(245,158,11,0.1); border: 1px solid rgba(245,158,11,0.3); padding: 12px; border-radius: 8px; margin-bottom: 12px;">
          <div style="font-size: 11px; color: #FBBF24; font-weight: 700;">APPEAL GROUNDS & EVIDENCE</div>
          <div style="font-size: 13px; color: #F8FAFC;">New mitigating medical certificate photo & video statement submitted.</div>
        </div>

        <div class="evidence-section" style="margin-bottom: 12px;">
          <div class="evidence-title"><i class="ri-attachment-line"></i> Appeal Evidence Attachments</div>
          <div class="evidence-grid">
            <div class="evidence-chip video" onclick="openEvidenceModal('Student_Video_Explanation.mp4', 'video', '14.2 MB', 'Student video statement for Vice Chancellor Review Board.')">
              <i class="ri-video-fill"></i> Video_Statement.mp4
            </div>
            <div class="evidence-chip photo" onclick="openEvidenceModal('Medical_Certificate.jpg', 'photo', '1.9 MB', 'Medical evidence documentation.')">
              <i class="ri-image-fill"></i> Medical_Cert.jpg
            </div>
          </div>
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
  if (demoDateInput) {
    demoDateInput.value = tomorrow.toISOString().split('T')[0];
  }

  function updateSandbox() {
    if (!demoDateInput) return;
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

  if (demoDateInput && demoStatusSelect) {
    demoDateInput.addEventListener('change', updateSandbox);
    demoStatusSelect.addEventListener('change', updateSandbox);
    updateSandbox();
  }

  // How To Use Guide Role Switcher
  const guideRoleBtns = document.querySelectorAll('.guide-role-btn');
  const guideGrid = document.getElementById('guide-grid');

  const guideData = {
    student: [
      {
        step: '1',
        title: 'Track Case Progression Bar',
        desc: 'Log in with your Student ID to view your real-time Case Progression Bar (Intake → Hearing → Ruling → Final Resolution).',
        tip: 'Tip: Progress percentage updates automatically as case stages change.'
      },
      {
        step: '2',
        title: 'Attach Photos & Videos as Evidence',
        desc: 'Upload supporting photos of property damage or video recordings when reporting an incident or submitting an appeal.',
        tip: 'Tip: Supports JPEG, PNG, MP4, MOV video files up to 50MB.'
      },
      {
        step: '3',
        title: 'Hearings & Appeal Options',
        desc: 'Receive hearing date & venue details. Submit a 1-click appeal with supporting media attachments to the VC Board if eligible.',
        tip: 'Tip: Appeals must be submitted within the university policy timeframe.'
      }
    ],
    staff: [
      {
        step: '1',
        title: 'Inspect Assigned Queue & Media Evidence',
        desc: 'Review assigned cases, offender details, and attached photo/video evidence submitted by reporters.',
        tip: 'Tip: Preview videos and photo evidence directly within the case dashboard.'
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
        desc: 'Monitor university-wide case counts, progress completion rates, active sanctions, and department resolution speeds.',
        tip: 'Tip: Use search bar to filter by student ID or incident category.'
      },
      {
        step: '2',
        title: 'Appeals Review Panel & Media Inspection',
        desc: 'Inspect student appeal submissions. Review new photo & video evidence before issuing final decision.',
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

      if (guideGrid) {
        guideGrid.innerHTML = steps.map(s => `
          <div class="guide-step-card">
            <div class="guide-step-badge">${s.step}</div>
            <h3 class="guide-step-title">${s.title}</h3>
            <p class="guide-step-desc">${s.desc}</p>
            <div class="guide-tip-box">${s.tip}</div>
          </div>
        `).join('');
      }
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

  // Inject Evidence Modal Container
  const modalHTML = `
    <div class="sdms-modal-backdrop" id="evidenceModal">
      <div class="sdms-modal-content">
        <button class="sdms-modal-close" onclick="closeEvidenceModal()"><i class="ri-close-line"></i></button>
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
          <i id="modalIcon" class="ri-film-line" style="font-size: 22px; color: #BC6B03;"></i>
          <h4 id="modalTitle" style="font-size: 16px; margin: 0; color: #F8FAFC;">Evidence Preview</h4>
        </div>
        <div id="modalPlayerArea" style="height: 220px; background: #000; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; margin-bottom: 14px; position: relative;">
          <!-- Injected via JS -->
        </div>
        <div style="font-size: 12px; color: #94A3B8;" id="modalDesc">
          Evidence attachment notes
        </div>
      </div>
    </div>
  `;
  document.body.insertAdjacentHTML('beforeend', modalHTML);
});

// Global functions for modal evidence viewer
window.openEvidenceModal = function(fileName, type, size, desc) {
  const modal = document.getElementById('evidenceModal');
  const title = document.getElementById('modalTitle');
  const icon = document.getElementById('modalIcon');
  const playerArea = document.getElementById('modalPlayerArea');
  const descEl = document.getElementById('modalDesc');

  if (!modal) return;

  title.textContent = fileName;
  descEl.textContent = `Size: ${size} • ${desc}`;

  if (type === 'video') {
    icon.className = 'ri-video-line';
    icon.style.color = '#60A5FA';
    playerArea.innerHTML = `
      <div style="width: 54px; height: 54px; border-radius: 50%; background: #BC6B03; display: flex; align-items: center; justify-content: center; color: white; font-size: 28px; cursor: pointer; box-shadow: 0 0 20px rgba(188,107,3,0.6);">
        <i class="ri-play-fill" style="margin-left: 3px;"></i>
      </div>
      <div style="color: white; font-size: 14px; font-weight: 700; margin-top: 12px;">Playing Video Evidence...</div>
      <div style="color: #94A3B8; font-size: 12px; margin-top: 4px;">Duration: 00:45 • HD Resolution</div>
    `;
  } else {
    icon.className = 'ri-image-line';
    icon.style.color = '#BC6B03';
    playerArea.innerHTML = `
      <i class="ri-image-fill" style="font-size: 54px; color: #BC6B03;"></i>
      <div style="color: white; font-size: 14px; font-weight: 700; margin-top: 12px;">${fileName}</div>
      <div style="color: #94A3B8; font-size: 12px; margin-top: 4px;">Photo Image Evidence Preview</div>
    `;
  }

  modal.classList.add('open');
};

window.closeEvidenceModal = function() {
  const modal = document.getElementById('evidenceModal');
  if (modal) modal.classList.remove('open');
};
