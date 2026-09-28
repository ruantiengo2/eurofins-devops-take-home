using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Security.Principal;

// Modify only this account's service-logon right; preserve all other policy entries.
public static class ServiceLogonRight
{
    [StructLayout(LayoutKind.Sequential)]
    private struct ObjectAttributes
    {
        public uint Length;
        public IntPtr RootDirectory, ObjectName;
        public uint Attributes;
        public IntPtr SecurityDescriptor, SecurityQualityOfService;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct UnicodeString
    {
        public ushort Length, MaximumLength;
        public IntPtr Buffer;
    }

    [DllImport("advapi32.dll")]
    private static extern uint LsaOpenPolicy(IntPtr systemName, ref ObjectAttributes attributes, uint access, out IntPtr policy);
    [DllImport("advapi32.dll")]
    private static extern uint LsaAddAccountRights(IntPtr policy, byte[] sid, UnicodeString[] rights, uint count);
    [DllImport("advapi32.dll")]
    private static extern uint LsaRemoveAccountRights(IntPtr policy, byte[] sid, [MarshalAs(UnmanagedType.U1)] bool allRights, UnicodeString[] rights, uint count);
    [DllImport("advapi32.dll")]
    private static extern uint LsaClose(IntPtr policy);
    [DllImport("advapi32.dll")]
    private static extern uint LsaNtStatusToWinError(uint status);

    private static void Check(uint status)
    {
        if (status != 0) throw new Win32Exception((int)LsaNtStatusToWinError(status));
    }

    public static void Grant(string sid) { Change(sid, true); }
    public static void Revoke(string sid) { Change(sid, false); }

    private static void Change(string sidText, bool grant)
    {
        var sid = new SecurityIdentifier(sidText);
        var bytes = new byte[sid.BinaryLength];
        sid.GetBinaryForm(bytes, 0);
        var attributes = new ObjectAttributes { Length = (uint)Marshal.SizeOf(typeof(ObjectAttributes)) };
        IntPtr policy = IntPtr.Zero;
        IntPtr buffer = IntPtr.Zero;
        try
        {
            // POLICY_LOOKUP_NAMES | POLICY_CREATE_ACCOUNT
            Check(LsaOpenPolicy(IntPtr.Zero, ref attributes, 0x810, out policy));
            const string right = "SeServiceLogonRight";
            buffer = Marshal.StringToHGlobalUni(right);
            var rights = new[] { new UnicodeString {
                Length = (ushort)(right.Length * 2),
                MaximumLength = (ushort)((right.Length + 1) * 2), Buffer = buffer
            } };
            Check(grant ? LsaAddAccountRights(policy, bytes, rights, 1)
                        : LsaRemoveAccountRights(policy, bytes, false, rights, 1));
        }
        finally
        {
            if (buffer != IntPtr.Zero) Marshal.FreeHGlobal(buffer);
            if (policy != IntPtr.Zero) LsaClose(policy);
        }
    }
}
