Use [XXXXXX]
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
SET @ScriptName = 'SYM65026-02 PK Brop Control Init.sql'
SET @Description = 'Init Calc for BROP Control'
SET @DataChange = 0
SET @FunctionalArea = 'Core'
SET @ObjectType = 'Table'
SET @ObjectName = 'Element Parameter Templates'
SET @Version = '2.4.3'
SET @SpecialInstructions = ''
SET @LoggedBy = 'Hannes Scheepers'
SET @VerifiedBy = 'Karen Steenkamp'
Exec SYMsp_SymplexityChangeCTRL 0, @User, @IssueNumber, @ScriptName, @Description, @DataChange, @FunctionalArea, @ObjectType, @ObjectName, @Version, @IDENTITY OUTPUT, @tbRT, @LoggedBy

Begin Try
Begin Transaction
/********************************************************************
 Deletes
*********************************************************************/
	Delete from [Element Parameter Templates] Where [Parameter ID] ='507'

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
	'Initialisation' as [Template]
	,507 as [Parameter ID]
	,'Initialisation - Emp Control' as [Description]
	,'01 Jan 1901' as [Start Date]
	,'31 Dec 9999' as [End Date]
	,'N/A' as [Group]
	,'N/A' as [Criteria]
	,'N/A' as [Periods]
	,'Normal,Interim' as [Runtype]
	,'''!!------------------------------------------------------------------------
''!! Initialisation - Emp Control
''!!*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
''!!*  CONFIGURATION CONTROL
''!!*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
''!!* Modification history
''!!* Version | Date     | By  | Description
''!!* 1.0.00  | ??/??/?? | ??? | Create calculation
''!!* 1.14.01 | 30/06/14 | PKA | Add Emp Noivce Control
''!!* 1.14.02 | 27/05/16 | EJ  | PrvOTV bug fix 
''!!------------------------------------------------------------------------
''!!Previous calendar
''!!*****************
sPC =PrvOTV

vWrk=DateAdd("d",({Run Type Status Prev (Normal)}),"1-Jan-2000")
If vWrk = "01-Jan-2000" Then
	vWrk=DateAdd("d",-1,(vStrDtN))
End if

sTable  =           "Calendar Periods"
sFields =           "Start Date~01-Jan-1901,"
sFields = sFields &	"End Date~01-Jan-1901"
sWhere =  "[End Date] = ''" & cstr(vWrk) & "'' AND [RunType] = ''Normal'' AND [Calendar] = ''" & sPC & "''"

set vPrevCalendarPeriods = FieldLookup(cstr(stable),cstr(sfields),cstr(swhere))

if cDate(vPrevCalendarPeriods("Start Date")) < cDate(vREDED) Then
	vStrDtPr = cDate(vREDED)
Else
	vStrDtPr = cDate(vPrevCalendarPeriods("Start Date"))
End If

if cdate(vPrevCalendarPeriods("End Date")) > cdate(vREDTD) Then
	vEnDtPr = cDate(vREDTD)
Else
	vEnDtPr = cDate(vPrevCalendarPeriods("End Date"))
End If
If (cdate(vEnDtPr)="01-Jan-1901") OR (cdate(vEnDtPr)<cDate(vStrDtPr)) Then
	vEnDtPr=DateAdd("d",-1,(vStrDtN))
End If

''!!Emp Control ------------------------------------------------------------------
sTable  =                 "Emp Control"

sFields =                 "Rate of Pay~0"
sFields = sFields + "," + "Retirement Fund Option~NotFound"
sFields = sFields + "," + "Retirement Fund (Voluntary Amount)~0"
sFields = sFields + "," + "UIF Option~N/A"
sFields = sFields + "," + "Tax Option~N/A"
sFields = sFields + "," + "Leave Scheme~N/A"
sFields = sFields + "," + "Employee Status~N/A"
sFields = sFields + "," + "Time Office Register~N/A"
sFields = sFields + "," + "Rate Adj Amount~0"
sFields = sFields + "," + "Rate Make-up~0"
sFields = sFields + "," + "Artisan Bonus~0"
sFields = sFields + "," + "Prefunding~0"
sFields = sFields + "," + "TM3 make-up~0"
sFields = sFields + "," + "Car Allowance~0"

sWhere="[Start Date]<=''" & cstr(vEndtP) & "'' and [End Date]>=''" & cstr(vEndtP) & "''"

Set EmpControl = ResourceLookup(sTable, sFields, sWhere)


''!!BROP Control ------------------------------------------------------------------
sTable  =                 "Emp_Brop_Control_Header"

sFields =                 "BROP~0"


sWhere="[Start Date]<=''" & cstr(vEndtP) & "'' and [End Date]>=''" & cstr(vEndtP) & "''"

Set BROPControl = ResourceLookup(sTable, sFields, sWhere)


''!!Medical Scheme Control ------------------------------------------------------------------
sTable  =                 "Emp Medical Scheme"

sFields = "Medical Scheme Start Date~31-dec-9999"
sFields = sFields + "," + "Medical Scheme Fund~NotFound"
sFields = sFields + "," + "Medical Scheme Option~N/A"
sFields = sFields + "," + "Medical Scheme Membership Status~N/A"
sFields = sFields + "," + "Medical Scheme Number of Spouses~0"
sFields = sFields + "," + "Medical Scheme Number of Children~0"
sFields = sFields + "," + "Medical Scheme Number of Adult Dependants~0"
sFields = sFields + "," + "Medical Scheme Prefunding Age~0"
sFields = sFields + "," + "Medical Scheme Employee Contribution Override~0"
sFields = sFields + "," + "Medical Scheme Employer Contribution Override~0"

sWhere="[Start Date]<=''" & cstr(vEndtP) & "'' and [End Date]>=''" & cstr(vEndtP) & "''"

Set EmpMS = ResourceLookup(sTable, sFields, sWhere)

{Med Aid Dependents}:=EmpMS("Medical Scheme Number of Adult Dependants") + EmpMS("Medical Scheme Number of Children") + 1 + EmpMS("Medical Scheme Number of Spouses") 

 

vSql = "Select top 1 CP.[Period ID Subtypes] "
vSql = vSql & "From [Output Transactions] OT with (nolock) "
vSql = vSql & "Inner Join [Calendar Periods] CP with (nolock) On CP.[Period ID] = OT.[Period ID] "
vSql = vSql & "and CP.[Runtype] = ''Normal'' "
vSql = vSql & "Where OT.[Resource Tag]= " & GetResourceTag()
vSql = vSql & " and CP.[Period ID] < " & GetPeriod()
vSql = vSql & " Order By OT.[Period ID] Desc"

vPrevNormalPeriodIdSubType = modblayer.execute(vsql,3)

''!!Emp Novice Control ------------------------------------------------------------------
sTable  =                 "Emp Novice Control"

sFields =                 "Resource Tag~0"

sWhere="[Start Date]<=''" & cstr(vEndtP) & "'' and [End Date]>=''" & cstr(vEndtP) & "''"

Set EmpNoviceControl = ResourceLookup(sTable, sFields, sWhere)
' as [Calculation]
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
