Use [Sibanye Gold Limited]
/*------------------------------------------------------------------------------------------------------------------------------------------------------
  CONFIGURATION CONTROL																																
-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  Place description here
-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* Modification history
* Version | Date     | By  | Description
* 1.11.01 | 17 05 17 | NEB | Create
------------------------------------------------------------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @User VARCHAR(50), @IssueNumber VARCHAR(20), @ScriptName VARCHAR(100), @Description VARCHAR(500), @ChangeNumber VARCHAR(20)
DECLARE @IDENTITY INT, @SpecialInstructions VARCHAR(150), @DataChange Bit, @sMsg varchar(4000), @LoggedBy NVARCHAR(50)
Declare @tbRT ResourceTagTableType, @FunctionalArea varchar(50), @ObjectType varchar(50), @ObjectName varchar(50), @Version varchar(50), @VerifiedBy NVARCHAR(50)
SET @User = 'Pieter Kitshoff'
SET @IssueNumber = 'SYM65026'
SET @ScriptName = 'SYM65026-03 PK Brop Control Rates.sql'
SET @Description = 'Rates Calc for BROP Control'
SET @DataChange = 0
SET @FunctionalArea = 'Core'
SET @ObjectType = 'Table'
SET @ObjectName = 'Element Parameter Templates'
SET @Version = '2.4.3'
SET @SpecialInstructions = ''
SET @LoggedBy = 'Hannes Scheepers'
SET @VerifiedBy = 'Karen Steenkamp'
E
Begin Try
Begin Transaction
/********************************************************************
 Deletes
*********************************************************************/
	Delete from [Element Parameter Templates] Where [Parameter ID] ='100603'

/********************************************************************
 Insert into [Element Parameter Templates]
*********************************************************************/
Insert into [Element Parameter Templates](
	[Template]
	,[Parameter ID]
	,[Description]
	,[Start Date]
	,[End Date]
	,[Group]
	,[Criteria]
	,[Periods]
	,[Runtype]
	,[Calculation]
	,[Type]
)

Select
	'Initialisation2' as [Template]
	,100603 as [Parameter ID]
	,'Initialisation - Rates' as [Description]
	,'01 Jan 1901' as [Start Date]
	,'31 Dec 9999' as [End Date]
	,'N/A' as [Group]
	,'N/A' as [Criteria]
	,'N/A' as [Periods]
	,'Normal,Interim' as [Runtype]
	,'''!!------------------------------------------------------------------------
''!! Initialisation - rates
''!!*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
''!!*  CONFIGURATION CONTROL
''!!*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
''!!* Modification history
''!!* Version | Date     | By  | Description
''!!* 1.0.00  | ??/??/?? | ??? | Create calculation
''!!* 1.9.01  | 18/06/09 | PKA | Fund Salary set change (Issue 2707)
''!!* 1.11.01 | 19/01/11 | PKA | Change rate calculation for HO employees
''!!* 1.14.01 | 19/01/11 | PKA | Check for noivce
''!!* 1.16.01 | 11/08/16 | PKA | Add RTS 1 and 99 to fund salary pro-rata test
''!!* 1.16.02 | 13/09/16 | PKA | SYM57871 - add isCOM
''!!* 1.16.03 | 07/10/16 | PKA | SYM58287 - Add Rate calculations for Platinum
''!!------------------------------------------------------------------------
	
''!!Get Basic Rate
''!!--------------
If EmpControl("Rate of Pay") = 0 Then
	If EmpNoviceControl("Resource Tag") <> 0 Then
		{Basic Rate}:= GrpDesignationControl("Novice Rate")
	else
		{Basic Rate}:= GrpDesignationControl("Minimum Rate")
	End If
Else
   {Basic Rate}:= EmpControl("Rate of Pay")
End If


If BROPControl("BROP") <> 0 Then  
{Basic Rate}:=BROPControl("BROP")
 End If
 

If ({Basic Rate} = 0) Then
   {Basic Rate}:= GrpGradeControl("Minimum Rate")
End If



If (EmpControl("Employee Status") = "Temporary Employee") Then
{Basic Rate}:= {Basic Rate}+EmpControl("Rate Adj Amount") +  EmpControl("Car Allowance") + EmpControl("Rate Make-up") + EmpControl("Artisan Bonus") + EmpControl("Prefunding") + EmpControl("TM3 make-up") 
ElseIf (EmpControl("Employee Status") <> "Temporary Employee") Then
{Basic Rate}:= {Basic Rate}+EmpControl("Rate Adj Amount") +  EmpControl("Car Allowance") + EmpControl("Rate Make-up") + EmpControl("Artisan Bonus") + EmpControl("Prefunding") + EmpControl("TM3 make-up") + Round(GrpDesignationControl("Premium"),2)
End If

if isCOM({Payment ID},visCOMArr)=False then

   {Basic Rate}:={Benefit Value (Monthly)} 
End If

''!!Calculate 2002 Make up
''!!----------------------
v2002Makeup=v2002Makeup-{Basic Rate}-{Service Increment}

If v2002Makeup<0 Then
	v2002Makeup=0
End If


''!!Clear Leave Consilidation Table
''!!----------------------

vSQL ="DELETE FROM [dbo].[Emp Leave Consolidation] WHERE [Resource Tag] = " & cstr(vResourceTag) & " And [Period Id] = " & cstr(VPeriodid)
moDBlayer.execute vSQL,5

''!!----------------------
''!!Calculate Monthly rate - GOLD
''!!----------------------
If {Payment ID}<400 Then
	if isCOM({Payment ID},visCOMArr)=False then
		{Monthly Rate}:={Basic Rate}
	else
		{Monthly Rate}:=({Basic Rate}+{Service Increment}+v2002makeup+{Apprentice Qualification Group 1 (Co Cont)}+{Apprentice Qualification Group 2 (Co Cont)}+{Apprentice Qualification Group 3 (Co Cont)}+{Apprentice Qualification Group 4 (Co Cont)})
	End If

	If GrpDesignationControl("Remuneration Method") = "BRP" Then
	   {Monthly Rate}:= {Basic Rate}*77.5/100/13
	   {Annual Monthly Rate}:= Round(({Monthly Rate}*12),2)
	End If

	''!!Calculate Other Rates
	''!!---------------------
	{Daily Rate}:=	ROUND({Monthly Rate}/{Shifts in Month},5)
	{Weekly Rate}:={Monthly Rate}*6/26
	{Daily Rate}:=ROUND({Daily Rate},2)
	{Hourly Rate}:=ROUND(({Monthly Rate}*12/365/8),2)
	If {Payment ID} = 3 Then
	   {Hourly Rate}:=ROUND(({Monthly Rate}*12/260/8),2)
	End If
End If

''!!--------------------------------
''!!Calculate Monthly rate - OTHER
''!!--------------------------------
If {Payment ID}>399 Then
	if isCOM({Payment ID},visCOMArr)=False then
		{Monthly Rate}:={Basic Rate}
	else
		{Monthly Rate}:=({Basic Rate}+{Service Increment}+v2002makeup+{Apprentice Qualification Group 1 (Co Cont)}+{Apprentice Qualification Group 2 (Co Cont)}+{Apprentice Qualification Group 3 (Co Cont)}+{Apprentice Qualification Group 4 (Co Cont)})
	End If

	''!!---------------------
	''!!Calculate Other Rates
	''!!---------------------
	{Daily Rate}:=ROUND(({Monthly Rate}/{Days Per Month}),2)
	{Weekly Rate}:={Daily Rate}*{Days Per Week}
	{Hourly Rate}:=ROUND(({Monthly Rate}/{Hours Per Month}),2)
End If

vProrataFactorFS = vProrataFactor
If vProrataFactor <> 1 Then
	If {Engagement Status - Payroll} = 2 _
	OR {Engagement Status - Payroll} = 3 _
	OR {Termination Status - Payroll} = 2 _
	OR vRunTypeStatus = 1  _
	OR vRunTypeStatus = 99 Then
		vProrataFactorFS = 1
	End IF
End IF
IF {Termination Status - Payroll} = 3 Then
	vProrataFactorFS = 0
End IF

vMonthlyRateSave={Monthly rate}
vMonthlyRate={Monthly rate}

''!!Calculate Fund Salary
''!!---------------------
If vRunTypeStatus = 1 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 2 then 
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 3 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 4 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 5 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 7 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 9 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
ElseIf vRunTypeStatus = 15 then
	{Fund Salary}:=Round((vMonthlyRate*vProrataFactorFS),2)+{Fund Salary}
End if

vMWPFDBSFundSalary=Round(vMonthlyRate,2)
''!!****************************************************************************************
''!! Set Prev Accommodation Annual Earnings
''!!****************************************************************************************
vSQL = "ARMSsp_Acomo_Annual_Earnings " & cstr(GetResourceTag()) & ",''"  & cstr(GetPeriodEndDate) & "'',''" & vEmployeeCalendar & "''," & cstr({Basic Rate})
vAAE = moDBlayer.execute(vSQL, 2)
if not isempty(vAAE) then
  {Prev Accommodation Annual Earnings}:=vAAE(0,0)
Else
  {Prev Accommodation Annual Earnings}:=0
End if' as [Calculation]
	,'CALC' as [Type]
/****************************************************************************************
   If sucessful update Audit entry
****************************************************************************************/
Exec SYMsp_SymplexityChangeCTRL @IDENTITY, @User, @IssueNumber, @ScriptName, @Description, @DataChange, @FunctionalArea, @ObjectType, @ObjectName, @Version, @IDENTITY OUTPUT, @tbRT, @LoggedBy
COMMIT
End Try
/****************************************************************************************
   Error processing
****************************************************************************************/
Begin Catch
ROLLBACK
Set @sMsg = 'Error '+Convert(varchar(50),ERROR_NUMBER())+' on line '+Convert(varchar(50),ERROR_LINE())+' message text is "'+ERROR_MESSAGE()+'"'
Exec SYMsp_SymplexityChangeCTRL -1, @User, @IssueNumber, @ScriptName, @Description, @DataChange, @FunctionalArea, @ObjectType, @ObjectName, @Version, @IDENTITY OUTPUT, @tbRT, @LoggedBy, @sMsg
RAISERROR ('%s',16, 1, @sMsg)
RAISERROR ('Transactions on script "%s" have been rolled back.',16, 1, @ScriptName)
End Catch
