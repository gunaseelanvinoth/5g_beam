% reports/generateArchitectureDiagram.m
function generateArchitectureDiagram()
    fprintf('Generating System Architecture and Flowchart Diagrams...\n');
    diagram_file = 'docs/architecture.md';
    
    fid = fopen(diagram_file, 'w');
    
    % Write Architecture Diagram
    fprintf(fid, '# System Architecture Diagram\n\n');
    fprintf(fid, '```mermaid\n');
    fprintf(fid, 'flowchart TD\n');
    fprintf(fid, '    A[5G Base Station] --> B[Multi-Beam Generation]\n');
    fprintf(fid, '    B --> C[Beamforming]\n');
    fprintf(fid, '    C --> D[mmWave Channel]\n');
    fprintf(fid, '    D --> E[Moving User Equipment]\n');
    fprintf(fid, '    E --> F[Mobility and Blockage]\n');
    fprintf(fid, '    F --> G[Channel Measurements]\n');
    fprintf(fid, '    G --> H[SNR / SINR / Received Power / BER]\n');
    fprintf(fid, '    H --> I[Dataset Generation]\n');
    fprintf(fid, '    I --> J[Preprocessing]\n');
    fprintf(fid, '    J --> K[Machine Learning Model]\n');
    fprintf(fid, '    K --> L[Failure Probability]\n');
    fprintf(fid, '    L --> M[Decision]\n');
    fprintf(fid, '    M --> N[Alternative Beam Evaluation]\n');
    fprintf(fid, '    N --> O[Beam Selection]\n');
    fprintf(fid, '    O --> P[Beam Switching]\n');
    fprintf(fid, '    P --> Q[Recovered Communication]\n');
    fprintf(fid, '    Q --> R[Performance Evaluation]\n');
    fprintf(fid, '```\n\n');
    
    % Write Flowchart comparing systems
    fprintf(fid, '# Conventional vs Proposed Flowchart\n\n');
    fprintf(fid, '```mermaid\n');
    fprintf(fid, 'flowchart LR\n');
    fprintf(fid, '    subgraph Conventional System\n');
    fprintf(fid, '        C1[Monitor Beam Quality] --> C2[Detect Failure]\n');
    fprintf(fid, '        C2 --> C3[Search Candidates]\n');
    fprintf(fid, '        C3 --> C4[Select Beam & Switch]\n');
    fprintf(fid, '    end\n');
    fprintf(fid, '    subgraph ML-Based Proactive System\n');
    fprintf(fid, '        M1[Monitor Beam Quality] --> M2[Predict Future Failure]\n');
    fprintf(fid, '        M2 --> M3{Prob > Threshold?}\n');
    fprintf(fid, '        M3 -- Yes --> M4[Select Beam & Proactive Switch]\n');
    fprintf(fid, '        M3 -- No --> M1\n');
    fprintf(fid, '    end\n');
    fprintf(fid, '```\n');
    
    fclose(fid);
    fprintf('Architecture diagrams generated at %s\n', diagram_file);
end
