USE [Sibanye Gold Limited]
/*------------------------------------------------------------------------------------------------------------------------------------------------------
  CONFIGURATION CONTROL																																
-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  Place code here
-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* Modification history
* Version | Date     | By  | Description
* 1.9.01  | dd/mm/yy | ??? | Create
------------------------------------------------------------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
/****************************************************************************************
   Main Code
****************************************************************************************/
/*------------------------------------------------------------------
	Sub section
-------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------------
  CONFIGURATION CONTROL																																
-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  Place code here
-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
* Modification history
* Version | Date     | By  | Description
* 1.9.01  | dd/mm/yy | ??? | Create
------------------------------------------------------------------------------------------------------------------------------------------------------*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
/****************************************************************************************
   Main Code
****************************************************************************************/
/*------------------------------------------------------------------
	Sub section
-------------------------------------------------------------------*/

-------------------------------------------------------------------------------------------------------------------------


INSERT INTO [dbo].[Grp Remuneration Method Control]
        ( [Start Date] ,
          [End Date] ,
          [Operation] ,
          [Remuneration Method] ,
          [Service Increment Percentage] ,
          [Maximum Service Increment Percentage] ,
          [Retirement Fund] ,
          [Group Life Cover] ,
          [Medical Scheme Fund]
        )
SELECT grmc.[Start Date] ,
       grmc.[End Date] ,
       'RPM' ,
       grmc.[Remuneration Method] ,
       grmc.[Service Increment Percentage] ,
       grmc.[Maximum Service Increment Percentage] ,
       grmc.[Retirement Fund] ,
       grmc.[Group Life Cover] ,
       grmc.[Medical Scheme Fund] FROM [dbo].[Grp Remuneration Method Control] AS [grmc] WHERE [grmc].[Operation] = 'Kroondal'



INSERT INTO [dbo].[ReconOperations]
        ( [Operation] )
VALUES  ( N'RPM'  -- Operation - nvarchar(50)
          )


		

		  INSERT INTO [dbo].[User Prompts]
		          ( [Prompt] ,
		            [Field Value] ,
		            [Field Description] ,
		            [Codeset] ,
		            [TA Code] ,
		            [Active]
		          )
		  VALUES  ( N'Employer' , -- Prompt - nvarchar(50)
		            N'0803' , -- Field Value - nvarchar(50)
		            N'RPM' , -- Field Description - nvarchar(50)
		            N'0020701' , -- Codeset - nvarchar(10)
		            N'804' , -- TA Code - nvarchar(50)
		            null  -- Active - nvarchar(50)

-------------------------------------------------------------------------------------------------------------------------
go

DECLARE @User VARCHAR(50), @IssueNumber VARCHAR(20), @ScriptName VARCHAR(100), @Description VARCHAR(500), @ChangeNumber VARCHAR(20)
DECLARE @IDENTITY INT, @SpecialInstructions VARCHAR(150), @DataChange Bit, @sMsg varchar(4000), @LoggedBy NVARCHAR(50), @VerifiedBy NVARCHAR(50)
Declare @tbRT ResourceTagTableType, @FunctionalArea varchar(50), @ObjectType varchar(50), @ObjectName varchar(50), @Version	varchar(50)
SET @User = 'Pieter Kitshoff'
SET @IssueNumber = 'SYM65026'
SET @ScriptName = 'SYM65026-01 PK Setup SI and Recon.sql'
SET @Description = 'Setup SI and Recon'
SET @DataChange = 1
SET @FunctionalArea = 'Payroll'
SET @ObjectType = 'TABLE' -- 'TABLE', 'VIEW', 'STORED PROC','FUNCTION', 'INDEX', 'CONSTRAINT'
SET @ObjectName = 'User Prompts' 
SET @Version = '2.4.2'
SET @SpecialInstructions = ''
SET @LoggedBy = 'Hannes Scheepers'
SET @VerifiedBy = 'Annemarie Wessels'
Set @Identity = -1

Exec SYMsp_SymplexityChangeCTRL 1, @User, @IssueNumber, @ScriptName, @Description, @DataChange, @FunctionalArea, @ObjectType, @ObjectName, @Version, @IDENTITY OUTPUT, @tbRT, @LoggedBy
GO
