'#
'# win_checks.vbs
'# Found on http://serverfault.com/questions/183663/how-can-i-find-out-how-many-updates-are-waiting-to-be-installed-on-a-remote-serv
'# see also http://lab4.org/wiki/Zabbix_windowsupdates_monitoren
'# Modified by Thorsten Kramm
'# Modified by Ton Koks
'# Added CheckServerUpdateStatus
'# Usage: cscript win_checks.vbs {Zabbix-Hostname of this system}

Option Explicit
Dim strServer        : strServer         =  "localhost"
Dim zbxHostname      : zbxHostname       =  GetArgValue(0,"localhost")

CheckServerUpdateStatus strServer
CheckFirewallStatus
WScript.Quit(0)



Function CheckServerUpdateStatus( ByVal strServer )

    '# WScript.Echo vbCRLF & "Connecting to " & strServer & " to check software update status..."

    Dim blnRebootRequired    : blnRebootRequired     = False
    Dim blnRebootPending     : blnRebootPending     = False
    Dim objSession        : Set objSession    = CreateObject("Microsoft.Update.Session", strServer)
    Dim objUpdateSearcher     : Set objUpdateSearcher    = objSession.CreateUpdateSearcher
    Dim objSearchResult    : Set objSearchResult     = objUpdateSearcher.Search(" IsAssigned=1 and IsHidden=0 and Type='Software'")

    Dim i, objUpdate
    Dim intPendingInstalls    : intPendingInstalls     = 0

    For i = 0 To objSearchResult.Updates.Count-1
        Set objUpdate = objSearchResult.Updates.Item(I)

        If objUpdate.IsInstalled Then
            If objUpdate.RebootRequired Then
                blnRebootPending     = True
            End If
        Else
            intPendingInstalls    = intPendingInstalls + 1
            'If objUpdate.RebootRequired Then    '### This property is FALSE before installation and only set to TRUE after installation to indicate that this patch forced a reboot.
            If objUpdate.InstallationBehavior.RebootBehavior <> 0 Then
                '# http://msdn.microsoft.com/en-us/library/aa386064%28v=VS.85%29.aspx
                '# InstallationBehavior.RebootBehavior = 0    Never reboot
                '# InstallationBehavior.RebootBehavior = 1    Must reboot
                '# InstallationBehavior.RebootBehavior = 2    Can request reboot
                blnRebootRequired     = True
            End If

        End If
    Next

    WScript.Echo zbxHostname & " windows.updates.pending " & intPendingInstalls

    If blnRebootRequired Then
        WScript.Echo zbxHostname & " windows.reboot.required 1"
    Else
        WScript.Echo zbxHostname & " windows.reboot.required 0"
    End If

    If blnRebootPending Then
        WScript.Echo zbxHostname & " windows.reboot.to_complete 1"
    Else
        WScript.Echo zbxHostname & " windows.reboot.to_complete 0"
    End If
End Function



Function GetArgValue( intArgItem, strDefault )
    If WScript.Arguments.Count > intArgItem Then
        GetArgValue = WScript.Arguments.Item(intArgItem)
    Else
        GetArgValue = strDefault
    End If
End Function



Function CheckFirewallStatus
    ' Profile Type
    Const NET_FW_DOMAIN = 1
    Const NET_FW_PRIVATE = 2
    Const NET_FW_PUBLIC = 4

    ' Create the FwPolicy2 object.
    Dim fwPolicy2
    Set fwPolicy2 = CreateObject("HNetCfg.FwPolicy2")

    if fwPolicy2.FirewallEnabled(NET_FW_DOMAIN) = TRUE then
        WScript.Echo zbxHostname & " windows.firewall.domain 1"
    else
        WScript.Echo zbxHostname & " windows.firewall.domain 0"
    end if

    if fwPolicy2.FirewallEnabled(NET_FW_PRIVATE) = TRUE then
        WScript.Echo zbxHostname & " windows.firewall.private 1"
    else
        WScript.Echo zbxHostname & " windows.firewall.private 0"
    end if

   if fwPolicy2.FirewallEnabled(NET_FW_PUBLIC) = TRUE then
       WScript.Echo zbxHostname & " windows.firewall.public 1"
   else
       WScript.Echo zbxHostname & " windows.firewall.public 0"
   end if
End Function