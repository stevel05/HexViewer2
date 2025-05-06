B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private fx As JFX
End Sub
#Region Menu Utils
'Set a shortcut key for this menu item
'Returns the menu item
Public Sub SetShortCutKey(MI As JavaObject,Combination() As String) As MenuItem
	Dim KC As JavaObject
	KC.InitializeStatic("javafx.scene.input.KeyCombination")
	Dim KCS As String
	For i = 0 To Combination.Length - 1
		If i > 0 Then KCS = KCS & "+"
		KCS = KCS & Combination(i)
	Next
	MI.RunMethod("setAccelerator",Array(KC.RunMethod("keyCombination",Array(KCS))))
	Return MI
End Sub

Public Sub MenuSeparatorItem As JavaObject
	Dim TJO As JavaObject
	TJO.InitializeNewInstance("javafx.scene.control.SeparatorMenuItem",Null)
	Return TJO
End Sub
#End Region Menu Utils

Public Sub CopyRange(B() As Byte,From As Int,ToIndex As Int) As Byte()
	Dim JO As JavaObject
	JO.InitializeStatic("java.util.Arrays")
	Return JO.RunMethod("copyOfRange",Array(B,From,ToIndex))
End Sub
Public Sub ByteArraysEquals(A1() As Byte, A2() As Byte) As Boolean
	Dim Arrays As JavaObject
	Arrays.InitializeStatic("java.util.Arrays")
	Return Arrays.RunMethod("equals",Array(A1,A2))
End Sub

Public Sub JoinBytes(ListOfArraysOfBytes As List) As Byte()
	Dim size As Int
	For Each b() As Byte In ListOfArraysOfBytes
		size = size + b.Length
	Next
	Dim result(size) As Byte
	Dim index As Int
	Dim bc As ByteConverter 'ByteConverter library
	For Each b() As Byte In ListOfArraysOfBytes
		bc.ArrayCopy(b, 0, result, index, b.Length)
		index = index + b.Length
	Next
	Return result
End Sub