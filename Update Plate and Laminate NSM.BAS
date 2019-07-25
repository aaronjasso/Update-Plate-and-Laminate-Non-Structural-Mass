Sub Main
    Dim App As femap.model
    Set App = feFemap()

    '=============================================
    'Update the NSM on all selected properties at once to the same value
	'
	'Copyright (c) 2019 Aaron Jasso
    '
    'This program is free software: you can redistribute it and/or modify
    'it under the terms of the GNU General Public License as published by
    'the Free Software Foundation, either version 3 of the License, or
    '(at your option) any later version.
    '
    'This program is distributed in the hope that it will be useful,
    'but WITHOUT ANY WARRANTY; without even the implied warranty of
    'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    'GNU General Public License for more details.
    '
    'You should have received a copy of the GNU General Public License
    'along with this program.  If not, see <https://www.gnu.org/licenses/>.
	'
	'Written by AMJ 4.10.2019
	'
	'Please comment or contribute at https://github.com/aaronjasso/Femap-Update-Plate-Laminate-NSM
    '=============================================
    Dim propSet As femap.Set
    Set propSet = App.feSet
    Dim iterProp As femap.Prop
    Set iterProp = App.feProp

    '=============================================
    'Prompt user for properties to update NSM
    '=============================================
    Dim rc As Variant
    Dim count, skipped As Long

    'The Select method is used to allow click-and-drag selection of visible
	'elements.	Swap the commented line below and use the SelectMultiID
	'if you prefer selecting from a list instead.

    rc = propSet.Select(FT_PROP,True,"Select Properties to Update Nonstructural Mass")
	'rc = propSet.SelectMultiID(FT_PROP,1,"Select Properties to Update Nonstructural Mass")

    If rc = 2 Then
    	Exit Sub
    End If

	Begin Dialog UserDialog 400,168,"Update NSM" ' %GRID:10,7,1,1
		GroupBox 10,0,380,126,"Update Nonstructural Mass",.GroupBox1
		Text 30,21,340,35,"Enter value to update nonstructural mass on selected properties. Any previous NSM values will be overwritten.",.Text1
		TextBox 200,105,150,14,.NSM
		Text 50,105,150,14,"Nonstructural Mass:",.Text2,1
		OKButton 30,133,160,28
		PushButton 210,133,160,28,"Cancel",.PushButton1
		Text 30,63,340,28,"NOTE: This will only update NSM values on PLATE or LAMINATE elements.",.Text3
	End Dialog
	Dim dlg As UserDialog
	'Dialog dlg

	'handle cancel button
	If Dialog(dlg) = 1 Then
		Exit Sub
	End If

    '=============================================
    'Update NSMs and output results to message window
    '=============================================
	propSet.Reset
	count = 0
	skipped = 0
	While propSet.Next
		iterProp.Get(propSet.CurrentID)
		If iterProp.type = FET_L_PLATE Then
			iterProp.pval(7) = dlg.NSM
			rc = iterProp.Put(iterProp.ID)
			If rc = -1 Then
				count = count + 1
			End If
		ElseIf iterProp.type = FET_L_LAMINATE_PLATE Then
			iterProp.pval(1) = dlg.nsm
			rc = iterProp.Put(iterProp.ID)
			If rc = -1 Then
				count = count + 1
			End If
		Else
			skipped = skipped + 1
		End If
	Wend

	App.feAppMessage(FCM_NORMAL, count & " properties updated")
	App.feAppMessage(FCM_NORMAL, skipped & " non-plate/laminate properties skipped")



End Sub
