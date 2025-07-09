<div align="center">

# SilentStub

<img src="https://github.com/user-attachments/assets/a62fbdba-d19f-4d3d-bc5d-cbd07750eecf" alt="SilentStub Logo" width="450">

### AMSI Bypass

</div>
<section>
  <h1>🛡 AMSI Bypass via RPC Hijack (<code>NdrClientCall3</code>)</h1>
  <p>
    A sophisticated AMSI evasion that subverts the RPC layer instead of tampering with public AMSI APIs. By injecting a hook into the low‑level 
    <code>rpcrt4.dll!NdrClientCall3</code> routine—the core RPC marshaller used by AMSI stubs—you can intercept and rewrite scan requests on the fly.
  </p>

  <h2>🔍 Under the Hood</h2>
  <ul>
    <li>
      <strong>Parameter Interception:</strong>
      Capture and transparently rewrite the buffer arguments passed to <code>NdrClientCall3</code>, so the AV engine only sees benign data while AMSI thinks it's scanning the real payload.
    </li>
    <li>
      <strong>Deep‑Layer Evasion:</strong>
      Operates one abstraction layer below common targets like <code>AmsiScanBuffer</code> and internal flags (e.g., <code>amsiInitFailed</code>), making detection by signature- or behavior-based defenses far less likely.
    </li>
    <li>
      <strong>Untouched <code>amsi.dll</code>:</strong>
      No modifications to the AMSI DLL itself—no altered exports or suspicious imports—so there are no tell‑tale signs for endpoint protection solutions to catch.
    </li>
  </ul>

  <h2>💡 Why Hook <code>NdrClientCall3</code>?</h2>
  <p>
    <code>NdrClientCall3</code> in <code>rpcrt4.dll</code> is responsible for marshaling function parameters and issuing the RPC to AV provider stubs generated from IDL. AMSI’s scanner communicates with AV modules via these stubs, all of which converge on <code>NdrClientCall3</code>. Hijacking this single entry point gives you complete control over AMSI’s data flow without ever touching its visible surface APIs.
  </p>
</section>
