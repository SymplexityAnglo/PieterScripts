SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

/*------------------------------------------------------------------
	Main section
--------------------------------------------------------------*/
ALTER  PROCEDURE [dbo].[Rpt_GFL_Payslip_Basic_sp]
    @DateFrom VARCHAR(11) ,
    @DateTo VARCHAR(11) ,
    @Calendar VARCHAR(50) ,
    @Runtype VARCHAR(50) ,
    @Completed VARCHAR(3) ,
    @Operation VARCHAR(50) ,
    @PayPoint VARCHAR(50) ,
    @PaymentID VARCHAR(50) ,							--NH ZA-1124836
    @Resource_Tag VARCHAR(50) ,
    @IndustryNumber VARCHAR(50) ,
    @RegenerateType VARCHAR(50) ,
    @Password VARCHAR(50) ,
    @Origin VARCHAR(50) ,
    @printYORN VARCHAR(3)
AS 
--EXEC Rpt_GFL_Payslip_Basic_sp '01-mar-2017', '31-mar-2017', null, null, '', 'Kroondal', '', null, '2130280164', '', 'original', 'GFL123', 'Payslip', null  --grp non-permanent[amount ded]
--EXEC Rpt_GFL_Payslip_Basic_sp '01-mar-2017', '31-mar-2017', null, null, '', '', '', null,'' , '', 'Original', 'GFL123', 'Payslip', null
--EXEC Rpt_GFL_Payslip_Basic_sp '01 feb 2015', '30 APR 2015', null, null, null, 'Kloof', 'Termination', null, null, '', 'Original', 'GFL123', 'Payslip', null
-- ********************************************************************************************************************
-- PROCEDURE NAME 	: Rpt_GFL_Payslip_Basic_sp
-- REPORT NUMBER	: GFL0002
-- DESCRIPTION		: Feeding Stored Procedure for the GFL Payslip Basic Information (excluding the calendar).
--			: It is driven by linking elements to column numbers (1-11) in the table 
--			: Uses 'Element Document Parameters'. The elements and columns have to be linked to the 
--			: report name 'Payslip'.
--			: Execution Parameter is the Period ID for the payrun period
-- AUTHOR		: Wikus du Toit
-- DATE CREATED		: 26-JUN-2001
-- ********************************************************************************************************************
-- 						CHANGE HISTORY LOG
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 08-Jan-2002
-- AUTHOR		: Bradley Wheeler
-- CHANGE REFERENCE	: BW001
-- DESCRIPTION OF CHANGE: Table Changes
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 10-Feb-2002
-- AUTHOR		: Jannie Muller
-- CHANGE REFERENCE	: I-2687
-- DESCRIPTION OF CHANGE: Calendar Description added
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 11-Apr-2003
-- AUTHOR		: Bradley Wheeler
-- CHANGE REFERENCE	: SELF RAISED
-- DESCRIPTION OF CHANGE: Redefined Payslip to run faster
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 14-Apr-2003
-- AUTHOR		: Bradley Wheeler
-- CHANGE REFERENCE	: SELF RAISED
-- DESCRIPTION OF CHANGE: Fixed up Interim Termination Calendars and added in a new Message system
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 22-Jan-2004
-- AUTHOR		: Bradley Wheeler
-- CHANGE REFERENCE	: 519825
-- DESCRIPTION OF CHANGE: When a person has 2 or more consecutive actings, this confuses the payslip. Fix for it.
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 08-Mar-2004
-- AUTHOR		: Bradley Wheeler
-- CHANGE REFERENCE	: 557143
-- DESCRIPTION OF CHANGE: Exclude Earnings with zero amounts
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 30-Jun-2004
-- AUTHOR		: Ronel Raath
-- CHANGE REFERENCE	: 661413
-- DESCRIPTION OF CHANGE: Insert Case statement to select Passport Number when ID Number = ''
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 23-Aug-2004
-- AUTHOR		: Bradley Wheeler
-- CHANGE REFERENCE	: 
-- DESCRIPTION OF CHANGE: 1. Simplify #SE Table
--			  2. Remove Redundant Code
--			  3. Insert YTD, Leave and BRP Values
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 15-Sep-2004
-- AUTHOR		: Ina Johns
-- CHANGE REFERENCE	: V4 Issue no 737613
-- DESCRIPTION OF CHANGE: Move the check for the Pay point from the JOIN statement to a WHERE clause
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 28 Feb 2006
-- AUTHOR		: Natanya Holzinger
-- CHANGE REFERENCE	: GRP Project Issue ZA-1124836 
-- DESCRIPTION OF CHANGE: Add Payment ID parameter & field - payslip is required to split for GRP-DE.
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 08 Jun 2006
-- AUTHOR		: Ina Johns
-- CHANGE REFERENCE	: Issue 1396189 PVCS vs 2.1
-- DESCRIPTION OF CHANGE: Increase the number of accumulators from 20 to 25
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 22-Aug-2006
-- AUTHOR		: Dina Kassen
-- CHANGE REFERENCE	: Issue no 1495601 PVCS vs 2.2
-- DESCRIPTION OF CHANGE: Change 'Income security' to 'rate adj reason' with the contents of the 'rate adj reason'.
-- 			  Add the Clocker with the contents of the clocker field.
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 03 Jan 2007
-- AUTHOR			: Ina Johns
-- CHANGE REFERENCE	: Request No ZA-01662947
-- DESCRIPTION OF CHANGE: Replace the Medical Dependants with the Medical Option
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 26 Sep 2007
-- AUTHOR		: Rosa Sasser
-- CHANGE REFERENCE	: Request No NEW GRP-309c
-- DESCRIPTION OF CHANGE: Read Clocker Status from Emp Clocker - If not Exist - Clocker Status = 'Yes'
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 04 Oct 2007
-- AUTHOR		: Rosa Sasser
-- CHANGE REFERENCE	: Request No ZA-2107019
-- DESCRIPTION OF CHANGE: Change 'Payment id' JOIN to OUTER JOIN and add ISNULL to Value
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 25 Oct 2007
-- AUTHOR			: Ina Johns
-- CHANGE REFERENCE	: Issue No ZA-02136282
-- DESCRIPTION OF CHANGE: The number of characters per employee is exceeding the maximum allowed by SQL. 
--						  Change the handling of the Calendar portion on the payslips from NVARCHAR to TEXT
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 05 Aug 2009
-- AUTHOR			: Petro Dyksman
-- CHANGE REFERENCE	: Issue No HEAT-4364
-- DESCRIPTION OF CHANGE: Add Rate Adj Amount to Rate of Pay for Standard Rate portion of "Basic Rate Make-up" portion of payslip
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 21 Aug 2009
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: Issue No HEAT-3100
-- DESCRIPTION OF CHANGE: Temp Employees should not get any message on payslip only Perm employees to recieve messages
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 16 Sep 2009
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: Issue No HEAT-3215
-- DESCRIPTION OF CHANGE: Add Payslip Language to the payslip header
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 05 Nov 2009
-- AUTHOR			: Petro Dyksman
-- CHANGE REFERENCE	: Issue No HEAT-4364
-- DESCRIPTION OF CHANGE: Change calculation for Standard Rate portion of "Basic Rate Make-up" - add all values from Emp Control into this field
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 04-Mar-2010
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: Heat Issue 9428
-- DESCRIPTION OF CHANGE: Change the Payment ID to read from the [RPT Period Mapping] table 
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 12-Mar-2010
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: Heat Issue 6739
-- DESCRIPTION OF CHANGE: Add Medical Certificate of Service Expiry Date to the Payslip 
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 12-Mar-2010
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: GFL00250
-- DESCRIPTION OF CHANGE: use different date for medical expiry date on payslip
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 30-Mar-2011
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: GFL02436
-- DESCRIPTION OF CHANGE: Add ESOP Message to Payslip for April 2011 run
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 17-Aug-2011
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: GFL01704
-- DESCRIPTION OF CHANGE: Add Compulsary Leave Forfeit elements for GFGS Employees
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 12-Oct-2012
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: SYM11718
-- DESCRIPTION OF CHANGE: Suppress Payslips for COM employees while on Leave
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 06-Feb-2013
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: SYM14669
-- DESCRIPTION OF CHANGE: Devide by zero error for GFGS
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 29-May-2013
-- AUTHOR			: Rosa Sasser
-- CHANGE REFERENCE	: SYM19548
-- DESCRIPTION OF CHANGE: View Previous Payslips - Change to point to 2012 tax year for old Operations
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 15-Jul-2014
-- AUTHOR			: Anton Beukes
-- CHANGE REFERENCE	: SYM36515
-- DESCRIPTION OF CHANGE: If the Termination Type = Transfer then do not show the temination date op the payslip
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 21-Nov-2014
-- AUTHOR			: Etienne Jordaan
-- CHANGE REFERENCE	: SYM39045
-- DESCRIPTION OF CHANGE: Add 'XXXdo not print' pay point
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 06-Feb-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM38472
-- DESCRIPTION OF CHANGE: Add a break Up for Basic rate of pay to the payslip tate column
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 18-Feb-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM41149
-- DESCRIPTION OF CHANGE: Change SYM39045 to allow online printing if do not print
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 11-Mar-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM40913
-- DESCRIPTION OF CHANGE: Add Leave due date, tax start date and medical Dependants fields to payslip
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 02-Apr-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM43246
-- DESCRIPTION OF CHANGE: Change the units standby to display days and not percentage
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 12-May-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM44034
-- DESCRIPTION OF CHANGE: Deduct a year from 'Compulsory Leave Due Date-Start' for GRP leave due date
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 29-Jul-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM47509
-- DESCRIPTION OF CHANGE: Create Index on temp tables because sort was ignored
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 18-Nov-2015
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM50765
-- DESCRIPTION OF CHANGE: Change SP to look at from service increment in Emp ta detail when employee is acting
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 13-Apr-2016
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM54698
-- DESCRIPTION OF CHANGE: All Payslips should print when termination payslip.
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 08-Jun-2016
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM55876
-- DESCRIPTION OF CHANGE: Do not add priemium amount to rate make-up before C2 May.
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 13-Jul-2016
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM57009
-- DESCRIPTION OF CHANGE: Remove isnull from package details
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 03-Oct-2016
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM58730
-- DESCRIPTION OF CHANGE: Platinum Payment id`s
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 06-Dec-2016
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM60927
-- DESCRIPTION OF CHANGE: Add Packages for Platinum GRp Employees
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 27-Mar-2017
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM62248
-- DESCRIPTION OF CHANGE: Change Sp to create deduction table for subreport in crystal
-- ********************************************************************************************************************
-- DATE OF CHANGE	: 11-Apr-2017
-- AUTHOR			: Annemarie Wessels
-- CHANGE REFERENCE	: SYM64331
-- DESCRIPTION OF CHANGE: Change the leave columns to display 3 decial places
-- ********************************************************************************************************************
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--OPRresourcetag=2130229520;rptearmsuser=EZLReports;rptearmsstructure=Organisation;@DateFrom=06-Jan-2015;@DateTo=22-Jan-2015;@Calendar=;@RunType=;@Completed=Yes;@Operation=Ezulwini;@PayPoint=RE4 - XXXdo not print;@RegenerateType=Original;@Password=GFL123;@Origin=Payslip
--DECLARE @DateFrom	VARCHAR(11)	= '01-feb-2017',
--	@DateTo		VARCHAR(11)		= '28-feb-2017',
--	@Calendar	VARCHAR(50)		= '',
--	@Runtype	VARCHAR(50)		= '',
--	@Completed	VARCHAR(3)		= 'Yes',
--	@Operation	VARCHAR(50)		= '',
--	@PayPoint	VARCHAR(50)		= '',
--	--@PayPoint	VARCHAR(50)		=null,
--	@PaymentID	VARCHAR(50)		= null ,							--NH ZA-1124836
--	@Resource_Tag	VARCHAR(50)		=2130276188 ,
--	@IndustryNumber	VARCHAR(50)		=null ,
--	@RegenerateType	VARCHAR(50)		='Original',
-- 	@Password	VARCHAR(50)		='GFL123',
--	@Origin		VARCHAR(50)	='Payslip'

--		IF (SELECT OBJECT_ID(N'Tempdb..#Calendar')) IS NOT NULL
--		DROP TABLE #Calendar
--		IF (SELECT OBJECT_ID(N'Tempdb..#SE')) IS NOT NULL
--		DROP TABLE #SE
--		IF (SELECT OBJECT_ID(N'Tempdb..#Co_Detail')) IS NOT NULL
--		DROP TABLE #Co_Detail
--		IF (SELECT OBJECT_ID(N'Tempdb..#Header_Footer')) IS NOT NULL
--		DROP TABLE #Header_Footer
--		IF (SELECT OBJECT_ID(N'Tempdb..#OT')) IS NOT NULL
--		DROP TABLE #OT
--		IF (SELECT OBJECT_ID(N'Tempdb..#YTD_Old')) IS NOT NULL
--		DROP TABLE #YTD_Old
--		IF (SELECT OBJECT_ID(N'Tempdb..#YTD')) IS NOT NULL
--		DROP TABLE #YTD
--		IF (SELECT OBJECT_ID(N'Tempdb..#Leave_Old')) IS NOT NULL
--		DROP TABLE #Leave_Old
--		IF (SELECT OBJECT_ID(N'Tempdb..#Leave')) IS NOT NULL
--		DROP TABLE #Leave
--		IF (SELECT OBJECT_ID(N'Tempdb..#BR_Old')) IS NOT NULL
--		DROP TABLE #BR_Old
--		IF (SELECT OBJECT_ID(N'Tempdb..#BR2')) IS NOT NULL
--		DROP TABLE #BR2
--		IF (SELECT OBJECT_ID(N'Tempdb..#BR')) IS NOT NULL
--		DROP TABLE #BR
--		IF (SELECT OBJECT_ID(N'Tempdb..#Leave_Dates')) IS NOT NULL
--		DROP TABLE #Leave_Dates
--		IF (SELECT OBJECT_ID(N'Tempdb..#Latest')) IS NOT NULL
--		DROP TABLE #Latest
--		IF (SELECT OBJECT_ID(N'Tempdb..#Previous')) IS NOT NULL
--		DROP TABLE #Previous
--		IF (SELECT OBJECT_ID(N'Tempdb..#REM_Latest')) IS NOT NULL
--		DROP TABLE #REM_Latest
--		IF (SELECT OBJECT_ID(N'Tempdb..#REM_Previous')) IS NOT NULL
--		DROP TABLE #REM_Previous
--		IF (SELECT OBJECT_ID(N'Tempdb..#GRP')) IS NOT NULL
--		DROP TABLE #GRP
--		IF (SELECT OBJECT_ID(N'Tempdb..#BRP')) IS NOT NULL
--		DROP TABLE #BRP
--		IF (SELECT OBJECT_ID(N'Tempdb..#Tmp_MCF')) IS NOT NULL
--		DROP TABLE #Tmp_MCF
--		IF (SELECT OBJECT_ID(N'Tempdb..#Distinct')) IS NOT NULL
--		DROP TABLE #Distinct
--      IF (SELECT OBJECT_ID(N'Tempdb..#maxleaveperiod')) IS NOT NULL
--	    DROP TABLE #maxleaveperiod
--	    IF (SELECT OBJECT_ID(N'Tempdb..#leavestartdate')) IS NOT NULL
--	    DROP TABLE #leavestartdate
--	    IF (SELECT OBJECT_ID(N'Tempdb..#taxstartdate')) IS NOT NULL
--	    DROP TABLE #taxstartdate
		--IF (SELECT OBJECT_ID(N'Tempdb..#leavestartdate11')) IS NOT NULL
	 --   DROP TABLE #leavestartdate11
	 --   IF (SELECT OBJECT_ID(N'Tempdb..#LatestPLT')) IS NOT NULL
	 --   DROP TABLE #LatestPLT
	 --   IF (SELECT OBJECT_ID(N'Tempdb..#PreviousPLT')) IS NOT NULL
	 --   DROP TABLE #PreviousPLT
		--IF (SELECT OBJECT_ID(N'Tempdb..#REM_LatestPLT')) IS NOT NULL
	 --   DROP TABLE #REM_LatestPLT
		--IF (SELECT OBJECT_ID(N'Tempdb..#REM_PreviousPLT')) IS NOT NULL
	 --   DROP TABLE #REM_PreviousPLT

    IF ( @Origin = 'View Payslip'
         AND LEN(@Resource_Tag) = 0
       )
        SELECT  @Resource_Tag = -1234567;

    IF ( @Origin = ''
         AND LEN(@Resource_Tag) = 0
       )
        SELECT  @Resource_Tag = -1234567;

    IF ISNULL(@Calendar, ' ') < '!'
        SELECT  @Calendar = '%';
    ELSE
        SELECT  @Calendar = REPLACE(( REPLACE(@Calendar, 'All', '%') ), '*',
                                    '%');
    IF ISNULL(@Runtype, ' ') < '!'
        SELECT  @Runtype = '%';
    ELSE
        SELECT  @Runtype = REPLACE(( REPLACE(@Runtype, 'All', '%') ), '*', '%');
    IF ISNULL(@Completed, ' ') < '!'
        SELECT  @Completed = '%';
    ELSE
        SELECT  @Completed = REPLACE(( REPLACE(@Completed, 'All', '%') ), '*',
                                     '%');
    IF ISNULL(@Operation, ' ') < '!'
        SELECT  @Operation = '%';
    ELSE
        SELECT  @Operation = REPLACE(( REPLACE(@Operation, 'All', '%') ), '*',
                                     '%');
    IF ISNULL(@Resource_Tag, ' ') < '!'
        SELECT  @Resource_Tag = '%';
    ELSE
        SELECT  @Resource_Tag = REPLACE(( REPLACE(@Resource_Tag, 'All', '%') ),
                                        '*', '%');
    IF ISNULL(@IndustryNumber, ' ') < '!'
        SELECT  @IndustryNumber = '%';
    ELSE
        SELECT  @IndustryNumber = REPLACE(( REPLACE(@IndustryNumber, 'All',
                                                    '%') ), '*', '%');
    IF ISNULL(@PayPoint, ' ') < '!'
        SELECT  @PayPoint = '%';
    ELSE
        SELECT  @PayPoint = REPLACE(( REPLACE(@PayPoint, 'All', '%') ), '*',
                                    '%');
--NH ZA-1124836
    IF ISNULL(@PaymentID, ' ') < '!'
        SELECT  @PaymentID = '%';
    ELSE
        SELECT  @PaymentID = REPLACE(( REPLACE(@PaymentID, 'All', '%') ), '*',
                                     '%');

    SET NOCOUNT ON;

-- Applying Payslip Security --
    DECLARE @Regen VARCHAR(50);
    DECLARE @PDate DATETIME;
    DECLARE @PCopy VARCHAR(255);
    DECLARE @POrig VARCHAR(255);

    SELECT  @PDate = MAX([Date])
    FROM    [Rpt Payslip Passwords];

    SELECT  @PCopy = [Copy] ,
            @POrig = [Original]
    FROM    [Rpt Payslip Passwords]
    WHERE   [Date] = @PDate;

    SET @PCopy = ( SELECT   dbo.Fn_Payslip_Encrypt(@PCopy)
                 );
    SET @POrig = ( SELECT   dbo.Fn_Payslip_Encrypt(@POrig)
                 );

    IF @RegenerateType = 'Copy'
        AND @Password = @PCopy
        BEGIN
            SET @Regen = 'Copy';
        END;
    ELSE
        BEGIN
            IF @RegenerateType = 'Original'
                AND @Password = @POrig
                BEGIN
                    SET @Regen = 'Original';
                END;
            ELSE
                BEGIN
                    SET @Regen = 'Dupl';
                END;
        END;

--select @Regen

-- Gathering Valid Period IDs --
    SELECT  *
    INTO    #Calendar
    FROM    [Calendar Periods] WITH ( NOLOCK )
    WHERE   @DateFrom <= CONVERT(DATETIME, LEFT([Sequence], 8))
            AND @DateTo >= CONVERT(DATETIME, LEFT([Sequence], 8))
            AND [Completed] LIKE '' + @Completed + ''
            AND [Calendar] LIKE '' + @Calendar + ''
            AND [RunType] LIKE '' + @Runtype + '';

--SELECT * FROM #Calendar

-- Finding Resource Tag if not specified for one person --
    IF @IndustryNumber != '%'
        BEGIN
            SET @Resource_Tag = ( SELECT    [Resource Tag]
                                  FROM      [Resource] WITH ( NOLOCK )
                                  WHERE     [Resource Reference] = @IndustryNumber
                                );
        END;

-- Gathering Primary Data --
    SELECT DISTINCT
            RPM.[Resource Tag] ,
            RPM.[Period Id] ,
            RPM.[Structure Entity] ,
            RPM.[Payment ID] ,
            C.[Calendar] ,
            C.[RunType] ,
            C.[Completed] ,
            C.[End Date] AS [Cal End Date] ,
            OS.[Operation] ,
            OS.[Designation] ,
	--RPI.[Tax Year], -- Removed SYM19548
	-- Added SYM19548
            CASE WHEN OS.[Operation] IN ( 'GFTS', 'GFPS', 'Shared Services',
                                          'GFWP', 'GFFH', 'GFFP', 'GFWH',
                                          'GFIMSA' ) THEN '2012'
                 ELSE RPI.[Tax Year]
            END AS [Tax Year] ,
	-- End SYM19548
            RPI.[PaySlip Number] ,
            TACD.[Tax Start Date] ,
            ISNULL(VVV.[Employee Number], 'NO VIP NO') AS [Employee number]
    INTO    #SE
    FROM    [Rpt Period Mapping] RPM WITH ( NOLOCK )
            INNER JOIN #Calendar C ON C.[Period ID] = RPM.[Period Id]
            INNER JOIN [Organisation Structure] OS WITH ( NOLOCK ) ON OS.[Structure Entity] = RPM.[Structure Entity]
                                                              AND OS.[Operation] LIKE @Operation
            INNER JOIN [Rpt Payslip Precalc Tbl] RPPT WITH ( NOLOCK ) ON RPPT.[Resource Tag] = RPM.[Resource Tag]
                                                              AND RPPT.[Period ID] = RPM.[Period Id]
            INNER JOIN [Rpt Payslip Info] RPI WITH ( NOLOCK ) ON RPI.[Resource Tag] = RPM.[Resource Tag]
                                                              AND RPI.[Period ID] = RPM.[Period Id]
            INNER JOIN [Tax Authority Calendar Dates] AS TACD WITH ( NOLOCK ) ON TACD.[Tax Year] = CASE
                                                              WHEN OS.[Operation] IN (
                                                              'GFTS', 'GFPS',
                                                              'Shared Services',
                                                              'GFWP', 'GFFH',
                                                              'GFFP', 'GFWH',
                                                              'GFIMSA' )
                                                              THEN '2012'
                                                              ELSE RPI.[Tax Year]
                                                              END
                                                              AND TACD.[Calendar] = C.[Calendar]
            LEFT OUTER JOIN [SGL_Sym_Backup].[conv].[PM_Resource Mapping] AS VVV ON VVV.[Resource Tag] = [RPM].[Resource Tag]
    WHERE   RPM.[Resource Tag] LIKE CASE WHEN @Regen = 'Dupl' THEN ''
                                         ELSE @Resource_Tag
                                    END;

-- select '#SE'
-- select * from #SE

-- Gathering Primary Company Data --
    SELECT DISTINCT
            SE.[Operation] ,
            SE.[Tax Year] ,
            CTR.[Trading Name] AS [Trading Name] ,
            CASE WHEN @Operation IN ( 'Kroondal', 'Blue Ridge' )
                 THEN [CTR].[Physical Address Line 1]
                 ELSE CTR.[Postal Address Line 1]
            END AS [Postal Address Line 1] ,
            CASE WHEN @Operation IN ( 'Kroondal', 'Blue Ridge' )
                 THEN [CTR].[Physical Address Line 2]
                 ELSE CTR.[Postal Address Line 2]
            END AS [Postal Address Line 2] ,
            CASE WHEN @Operation IN ( 'Kroondal', 'Blue Ridge' )
                 THEN [CTR].[Physical Address Postal Code]
                 ELSE CTR.[Postal Address Postal Code]
            END AS [Postal Address Postal Code] ,
            CTR.[Company ID] AS [CC/Trust/Co Reg. No],
			[CTR].[Default Employee Business Tel No] AS [CO Tel]
    INTO    #Co_Detail
    FROM    #SE SE
            INNER JOIN [Resource] R WITH ( NOLOCK ) ON R.[Resource Name] = SE.[Operation]
            INNER JOIN [CO TAX RSA] CTR WITH ( NOLOCK ) ON CTR.[Resource Tag] = R.[Resource Tag]
                                                           AND CTR.[Tax Year] = SE.[Tax Year];
--SELECT * FROM [Co Tax RSA] with (nolock)  WHERE [tax year] = '2018'
-- select '#Co_Detail'
-- select * from #Co_Detail

-- Gathering max period leave Data --


    SELECT DISTINCT
            SEE.[Resource Tag] ,
            MAX(md.[Period ID]) AS [comp_max_period] ,
            'Compulsory Leave Due Date-Start' AS [element]
    INTO    #maxleaveperiod
    FROM    #SE SEE
            INNER JOIN ( SELECT [Resource Tag] ,
                                [ot].[Period ID] AS [Period ID]
                         FROM   [Output Transactions] AS [ot]
                                INNER JOIN [Calendar Periods] C ON C.[Period ID] = [ot].[Period ID]
                                                              AND C.[Completed] = 'Yes'
                         WHERE  [Element] = 'Compulsory Leave Due Date-Start'
                       ) AS [md] ON [md].[Resource Tag] = [SEE].[Resource Tag]
                                    AND [md].[Period ID] <= SEE.[Period Id]

WHERE  ( SEE.[Payment ID] = 2
              OR SEE.[Payment ID] = 4  OR SEE.[Payment ID] = 201   
            )
    --WHERE   SEE.[Payment ID] NOT IN ( 1, 401 )
    GROUP BY SEE.[Resource Tag]
    UNION ALL
    SELECT DISTINCT
            SEE.[Resource Tag] ,
            MAX(md.[Period ID]) AS [comp_max_period] ,
            'Leave Due Date-start' AS [element]
    FROM    #SE SEE
            INNER JOIN ( SELECT [Resource Tag] ,
                                [ot].[Period ID] AS [Period ID]
                         FROM   [Output Transactions] AS [ot]
                                INNER JOIN [Calendar Periods] C ON C.[Period ID] = [ot].[Period ID]
                                                              AND C.[Completed] = 'Yes'
                         WHERE  [Element] = 'Leave Due Date-start'
                       ) AS [md] ON [md].[Resource Tag] = [SEE].[Resource Tag]
                                    AND [md].[Period ID] <= SEE.[Period Id]
  WHERE   ( SEE.[Payment ID] = 1
              OR SEE.[Payment ID] = 401  OR SEE.[Payment ID] = 501   OR SEE.[Payment ID] = 601 
            )
    GROUP BY SEE.[Resource Tag];


--select '#maxleaveperiod'
-- select * from #maxleaveperiod

    SELECT  [Resource Tag] ,
            MAX(comp_max_period) AS comp_max_Period
    INTO    #leavestartdate11
    FROM    #maxleaveperiod
    GROUP BY [Resource Tag];


    SELECT DISTINCT
            MLP.[Resource Tag] ,
	--Replace (CONVERT(VARCHAR(50),  (convert(date,cast(left(ott2.[output value],8)as Varchar(8)))) , 106),' ', '-') as  [leave due date start]
            CASE WHEN OTT2.Element = 'Compulsory Leave Due Date-Start'
                 THEN REPLACE(CONVERT(VARCHAR(50), ( DATEADD(YEAR, -1,
                                                             ( CONVERT(DATE, CAST(LEFT(OTT2.[Output Value],
                                                              8) AS VARCHAR(8))) )) ), 106),
                              ' ', '-')  --SYM44034
                 ELSE REPLACE(CONVERT(VARCHAR(50), ( CONVERT(DATE, CAST(LEFT(OTT2.[Output Value],
                                                              8) AS VARCHAR(8))) ), 106),
                              ' ', '-')
            END AS [leave due date start]
    INTO    #leavestartdate
    FROM    #leavestartdate11 AS MLP --#maxleaveperiod	 as MLP

--inner join [Rpt Period Mapping]		RPM	WITH (NOLOCK)
--                          on rpm.[Resource Tag] = MLP.[Resource Tag]
--						  and
--						  rpm.[period id] = MLP.[comp_max_period]
            INNER JOIN [Output Transactions] AS OTT2 ON MLP.[Resource Tag] = OTT2.[Resource Tag]
						   --and 
						   --MLP.[Element] = ott2.[element]
                                                        AND MLP.[comp_max_Period] = OTT2.[Period ID]
                                                        AND ( OTT2.[Element] = 'Compulsory Leave Due Date-Start'
                                                              OR OTT2.[Element] = 'Leave Due Date-start'
                                                            );
						   

 --select '#leavestartdate'
 --select * from #leavestartdate


-- Obtain Header And Footer Data for Payslip --
    SELECT DISTINCT
            SE.[Resource Tag] ,
            SE.[Period Id] ,
            SUBSTRING(SE.[Calendar], 7, 1) AS [Pay Cycle] ,
            SE.[RunType] AS [Payslip Type] ,
            R.[Resource Reference] AS [Resource Reference] ,
            SE.[Operation] AS [Operation] ,
            GDC.[Payslip Designation] AS [Designation] ,
            GDC.[Grade] AS [Grade] ,
            ISNULL(GDC.[Remuneration Method], 'Unknown') AS [Remuneration Method] ,
            SPD.[Family Name] AS [Surname] ,
            SPD.[Initials] AS [Initials] ,
            SPD.[Title] AS [Title] ,
            SPD.[Payslip Language] , -- ADDED HEAT 3215 RS
            SPED.[Group Engagement Date] AS [Group Engagement Date] ,
            SPED.[Engagement Date] AS [Mine Engagement Date] ,
            ISNULL(EC.[Rate Adj Reason], '') AS [Rate Adj Reason] ,		--Request 1495601 PVCS vs 2.2 add
            ISNULL(EC1.[Clocker], 'Yes') AS [Clocker] ,
            CASE WHEN ENC.[Resource Tag] IS NULL THEN 'No'
                 ELSE 'Yes'
            END AS [Novice] ,		--Request 1495601 PVCS vs 2.2 add
	--SYM36515
            CASE WHEN ET.[Termination Type] = 'Transfer' THEN ''
                 ELSE SPED.[Termination Date]
            END AS [Termination Date] ,
	--SYM36515
            CASE WHEN EB.[Payment Method] = 'TEBA' THEN EB.[Payment Method]
                 ELSE SBBC.[Bank Name]
            END AS [Bank] ,
            CASE WHEN EB.[Payment Method] = 'TEBA' THEN EB.[Branch]
                 ELSE SBBC.[Bank - Branch Code]
            END AS [Bank Branch Name] ,
            ISNULL(EB.[Account Type], '') AS [Account Type] ,
            ISNULL(EB.[Account Number], '') AS [Account Number] ,
            ISNULL(EPP.[Pay Point], 'Unknown') AS [Pay Point] ,
            CASE WHEN ISNULL(SRSD.[ID Number], '') = ''
                 THEN SRSD.[Passport Number]
                 ELSE SRSD.[ID Number]
            END AS [ID/Passport Number] ,
            ISNULL(EMS.[Medical Scheme Option], 'None') AS [Medical Dependants] ,
            SRTD.[Income Tax Reference Number] AS [Tax Reference Number] ,
            CASE WHEN SE.[Completed] != 'Yes' THEN 'Copy'
                 ELSE @Regen
            END AS [Copy] ,
            CONVERT(VARCHAR(25), SE.[Resource Tag]) + SE.[RunType] AS [Counter] ,
            CASE WHEN EC.[Employee Status] = 'Temporary Employee' THEN ''
                 ELSE GPM.[Message]
            END AS [Message] , --added HEAT-3100 RS
            SE.[Payslip Number] AS [Payslip Number] ,
            SE.[Tax Year] AS [Tax Year] ,
-- RS No ZA-2107019
            ISNULL(PIC.[Payment ID], 1.00000) AS [Payment ID] ,					--NH ZA-1124836,
            ISNULL(EC.[Leave Scheme], GDC.[Leave Scheme]) AS [Leave Scheme] ,
--,ISNULL(EPP.[Pay Point],'Unknown') ,
            ISNULL(EPM.[Print Normal Run Payslip], 'Yes') AS [Print Normal Run Payslip] ,
	--isnull(EPM.[Print Interim Run Payslip],'Yes')	as [Print Interim Run Payslip],
            CASE WHEN EPP.[Pay Point] = 'Termination' THEN 'Yes'
                 ELSE ISNULL(EPM.[Print Interim Run Payslip], 'Yes')
            END AS [Print Interim Run Payslip] ,

	--'M+'+'S'+ISNULL(CONVERT(VARCHAR(20),EMS.[Medical Scheme Number of Spouses]),'0')+'+'+'C'+ISNULL(CONVERT(VARCHAR(20),EMS.[Medical Scheme Number of Children]),'0')+'+'+'A'+ISNULL(CONVERT(VARCHAR(20),EMS.[Medical Scheme Number of Adult Dependants]),'0') AS [MED STATUS],
            CASE WHEN EMS.[Medical Scheme Option] IS NULL THEN ''
                 ELSE ( 'M'
                        + CASE WHEN EMS.[Medical Scheme Number of Spouses] = 0
                               THEN ''
                               ELSE '+' + 'S'
                                    + ISNULL(CONVERT(VARCHAR(20), EMS.[Medical Scheme Number of Spouses]),
                                             '0')
                          END
                        + CASE WHEN EMS.[Medical Scheme Number of Children] = 0
                               THEN ''
                               ELSE '+' + 'C'
                                    + ISNULL(CONVERT(VARCHAR(20), EMS.[Medical Scheme Number of Children]),
                                             '0')
                          END
                        + CASE WHEN EMS.[Medical Scheme Number of Adult Dependants] = 0
                               THEN ''
                               ELSE '+' + 'A'
                                    + ISNULL(CONVERT(VARCHAR(20), EMS.[Medical Scheme Number of Adult Dependants]),
                                             '0')
                          END )
            END AS [MED STATUS] ,
            [leave due date start] ,
            CASE WHEN ISNULL(SE.[Tax Start Date], '1901-Jan-01') <= SPED.[Engagement Date]
                 THEN SPED.[Engagement Date]
                 ELSE SE.[Tax Start Date]
            END AS [Employee Tax Start Date] ,
            [Employee number]
--ET2.*
    INTO    #Header_Footer
    FROM    #SE SE
            INNER JOIN [Resource] R WITH ( NOLOCK ) ON R.[Resource Tag] = SE.[Resource Tag]
            INNER JOIN [Sys Personal Employment Details] SPED WITH ( NOLOCK ) ON SPED.[Resource Tag] = SE.[Resource Tag]
                                                              AND SPED.[Termination Date] = ( SELECT
                                                              MAX(ISNULL(SPED2.[Termination Date],
                                                              '9999-12-31'))
                                                              FROM
                                                              [Sys Personal Employment Details] SPED2
                                                              WITH ( NOLOCK )
                                                              WHERE
                                                              SPED2.[Resource Tag] = SPED.[Resource Tag]
                                                              AND SPED2.[Engagement Date] <= SE.[Cal End Date]
                                                              )
--SYM36515
            LEFT OUTER JOIN [dbo].[Emp Termination] AS ET WITH ( NOLOCK ) ON ET.[Resource Tag] = SPED.[Resource Tag]
                                                              AND ET.[Termination Date] = SPED.[Termination Date]
                                                              AND ET.[Termination Type] = 'Transfer'
--SYM36515
--SYM39045
            LEFT OUTER JOIN [dbo].[Emp Termination] AS ET2 WITH ( NOLOCK ) ON ET2.[Resource Tag] = SPED.[Resource Tag]
                                                              AND ET2.[Period ID] = SE.[Period Id]
--SYM39045
            LEFT OUTER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= SE.[Cal End Date]
                                                              AND EC.[End Date] >= SE.[Cal End Date]
            LEFT OUTER JOIN [dbo].[Emp Novice Control] ENC WITH ( NOLOCK ) ON ENC.[Resource Tag] = SE.[Resource Tag]
                                                              AND ENC.[Start Date] <= SE.[Cal End Date]
                                                              AND ENC.[End Date] >= SE.[Cal End Date]
            LEFT OUTER JOIN [Emp Clocker] EC1 WITH ( NOLOCK ) ON EC1.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC1.[Start Date] <= SE.[Cal End Date]
                                                              AND EC1.[End Date] >= SE.[Cal End Date]
            LEFT OUTER JOIN [Grp Designation Control] GDC WITH ( NOLOCK ) ON GDC.[Designation] = SE.[Designation]
                                                              AND GDC.[Operation] = SE.[Operation]
                                                              AND GDC.[Start Date] <= SE.[Cal End Date]
                                                              AND GDC.[End Date] >= SE.[Cal End Date]
            LEFT OUTER JOIN [Sys Personal Details] SPD WITH ( NOLOCK ) ON SPD.[Resource Tag] = SE.[Resource Tag]
            LEFT OUTER JOIN [Emp Banking] EB WITH ( NOLOCK ) ON EB.[Resource Tag] = SE.[Resource Tag]
                                                              AND EB.[Start Date] <= SE.[Cal End Date]
                                                              AND EB.[End Date] >= SE.[Cal End Date]
            LEFT OUTER JOIN [Sys Bank - Branch Codes] SBBC WITH ( NOLOCK ) ON SBBC.[Bank Code] = EB.[Bank Name]
                                                              AND SBBC.[Branch Code] = EB.[Branch Code]
            LEFT OUTER JOIN [Emp Pay Point] EPP WITH ( NOLOCK ) ON EPP.[Resource Tag] = SE.[Resource Tag]
                                                              AND EPP.[Start Date] <= SE.[Cal End Date]
                                                              AND EPP.[End Date] >= SE.[Cal End Date]
--						AND	ISNULL(EPP.[Pay Point],'Unknown') LIKE	@PayPoint
            LEFT OUTER JOIN [Sys RSA Statutory Detail] SRSD WITH ( NOLOCK ) ON SRSD.[Resource Tag] = SE.[Resource Tag]
            LEFT OUTER JOIN [Sys RSA Tax Details] SRTD WITH ( NOLOCK ) ON SRTD.[Resource Tag] = SE.[Resource Tag]
                                                              AND SRTD.[Tax Start Date] <= SE.[Cal End Date]
                                                              AND SRTD.[Tax End Date] >= SE.[Cal End Date]
            LEFT OUTER JOIN [Grp Payslip Message] GPM WITH ( NOLOCK ) ON GPM.[Operation] = CASE
                                                              WHEN EXISTS ( SELECT
                                                              *
                                                              FROM
                                                              [Grp Payslip Message] GPM2
                                                              WHERE
                                                              GPM2.[Start Date] <= SE.[Cal End Date]
                                                              AND GPM2.[End Date] >= SE.[Cal End Date]
                                                              AND GPM2.[Operation] = SE.[Operation] )
                                                              THEN SE.[Operation]
                                                              ELSE 'ALL'
                                                              END
                                                              AND GPM.[Remuneration Method] = CASE
                                                              WHEN EXISTS ( SELECT
                                                              *
                                                              FROM
                                                              [Grp Payslip Message] GPM2
                                                              WHERE
                                                              GPM2.[Start Date] <= SE.[Cal End Date]
                                                              AND GPM2.[End Date] >= SE.[Cal End Date]
                                                              AND GPM2.[Operation] = SE.[Operation]
                                                              AND GPM2.[Remuneration Method] = GDC.[Remuneration Method] )
                                                              THEN GDC.[Remuneration Method]
                                                              WHEN EXISTS ( SELECT
                                                              *
                                                              FROM
                                                              [Grp Payslip Message] GPM2
                                                              WHERE
                                                              GPM2.[Start Date] <= SE.[Cal End Date]
                                                              AND GPM2.[End Date] >= SE.[Cal End Date]
                                                              AND GPM2.[Operation] = 'ALL'
                                                              AND GPM2.[Remuneration Method] = GDC.[Remuneration Method] )
                                                              THEN GDC.[Remuneration Method]
                                                              ELSE 'ALL'
                                                              END
                                                              AND GPM.[Start Date] <= SE.[Cal End Date]
                                                              AND GPM.[End Date] >= SE.[Cal End Date]
						-- ZA-01662947 Start of change
            LEFT OUTER JOIN [Emp Medical Scheme] EMS WITH ( NOLOCK ) ON SPED.[Resource Tag] = EMS.[Resource Tag]
                                                              AND EMS.[Start Date] <= SE.[Cal End Date]
                                                              AND EMS.[End Date] >= SE.[Cal End Date]
            INNER JOIN [Payment ID Control] PIC WITH ( NOLOCK ) ON PIC.[Payment ID Value] = SE.[Payment ID]
                                                              AND PIC.[Payment ID] LIKE @PaymentID
--End NH ZA-1124836
            LEFT JOIN [Emp Payslip Method] EPM ON EPM.[Resource Tag] = R.[Resource Tag]
            LEFT JOIN [dbo].[Rpt Period Mapping] RPM ON EPM.[Resource Tag] = R.[Resource Tag]
                                                        AND RPM.[Period Id] = SE.[Period Id]
            LEFT OUTER JOIN #leavestartdate AS LDDS ON LDDS.[Resource Tag] = R.[Resource Tag]	
--left outer join #taxstartdate as txsdt
--   on txsdt.[resource tag] = R.[resource tag]
--SYM39045
    WHERE   ISNULL(EPP.[Pay Point], 'Unknown') LIKE REPLACE(@PayPoint,
                                                            ' - XXXdo not print',
                                                            '');
--AND 
--	(CASE	WHEN @PayPoint LIKE '% - XXXdo not print%' 
--				THEN 'PART OF DONT PRINT BATCH' 
--				ELSE 'PART OF PRINT BATCH' 
--	 END) 
--= 
--	(CASE 
--		WHEN ET2.[Resource Tag] IS NOT NULL THEN 'PART OF PRINT BATCH'	-- Termination Run - Print
--		WHEN RPM.[Payment ID] LIKE '%GRP-DE%' THEN 'PART OF DONT PRINT BATCH' -- DE - Dont Print 
--		ELSE													-- Check to see if should print
--			(CASE	WHEN SE.[RunType] = 'Normal' THEN (CASE 
--													WHEN ISNULL(EPM.[Print Normal Run Payslip],'Yes') = 'Yes' THEN 'PART OF PRINT BATCH' 
--													ELSE 'PART OF DONT PRINT BATCH' 
--												END)	 
--					ELSE 
--						(CASE	WHEN ISNULL(EPM.[Print Interim Run Payslip],'Yes') = 'Yes' THEN 'PART OF PRINT BATCH' 
--								ELSE 'PART OF DONT PRINT BATCH' 
--						END)
--			  END)
--	 END)
--WHERE 	ISNULL(EPP.[Pay Point],'Unknown') LIKE	@PayPoint
-- and R.[Resource Reference] = 'Z4342312'
--SYM39045
--select * from #Header_Footer
--if isnull(@PaymentID,'') LIKE '%GRP-DE%'
--begin
--	delete FROM #Header_Footer where [Payslip Type] = 'Interim' and [Print Interim Run Payslip] = 'Yes'
--	delete FROM #Header_Footer where [Payslip Type] = 'Normal'	and [Print Normal Run Payslip] = 'Yes'
--end
-- select @PayPoint
--select @IndustryNumber
--SYM54698 Termination Payslip to print although not in termination paypoint
    UPDATE  A
    SET     [Print Interim Run Payslip] = 'Yes' ,
            [Pay Point] = REPLACE([Pay Point], ' XXXdo not print', '')
    FROM    #Header_Footer A
    WHERE   [Termination Date] <> '31-dec-9999';
--SYM54698

--SYM41149
    IF @Resource_Tag = '%'
        IF ISNULL(@PaymentID, '') NOT LIKE '%GRP-DE%'
            BEGIN

                IF ISNULL(@PayPoint, 'Unknown') LIKE '%XXXdo not print'
                    BEGIN

                        DELETE  FROM #Header_Footer
                        WHERE   [Payslip Type] = 'Interim'
                                AND [Print Interim Run Payslip] = 'Yes';
                        DELETE  FROM #Header_Footer
                        WHERE   [Payslip Type] = 'Normal'
                                AND [Print Normal Run Payslip] = 'Yes';
                    END;

                ELSE
                    BEGIN
                        DELETE  FROM #Header_Footer
                        WHERE   [Payslip Type] = 'Interim'
                                AND [Print Interim Run Payslip] = 'No';
                        DELETE  FROM #Header_Footer
                        WHERE   [Payslip Type] = 'Normal'
                                AND [Print Normal Run Payslip] = 'No';

                    END;
            END;
--SYM41149
--select * from #Header_Footer


--return

--Start NH ZA-1124836
    IF @PaymentID = '%'
        AND @Resource_Tag = '%'
        BEGIN
            DELETE  FROM #Header_Footer
            WHERE   [Payment ID] LIKE '%GRP-DE%';
        END;
--End NH ZA-1124836

 --select '#Header_Footer'
 --select * from #Header_Footer --19474
 --DELETE FROM #Header_Footer 

-- Update Payslip Security Table --
    UPDATE  [Rpt Payslip Info]
    SET     [Rpt Payslip Info].[Number of Originals] = [Rpt Payslip Info].[Number of Originals]
            + ( CASE WHEN T1.[Copy] = 'Original' THEN 1
                     ELSE 0
                END ) ,
            [Rpt Payslip Info].[Number of Copies] = [Rpt Payslip Info].[Number of Copies]
            + ( CASE WHEN T1.[Copy] = 'Original' THEN 1
                     ELSE 0
                END )
    FROM    #Header_Footer T1
    WHERE   [Rpt Payslip Info].[Resource Tag] = T1.[Resource Tag]
            AND [Rpt Payslip Info].[Period ID] = T1.[Period Id];

-- Gathering All output transactions used for this script --
    SELECT DISTINCT
            OT.[Resource Tag] ,
            OT.[Period ID] ,
            OT.[Element] ,
            OT.[Output Value] ,
-- RS No ZA-2107019
            ISNULL(PIC.[Payment ID], 1.00000) AS [Payment ID]--NH ZA-1124836
    INTO    #OT
    FROM    #SE SE
            INNER JOIN [Element Document Parameters] EDP WITH ( NOLOCK ) ON EDP.[Document] IN (
                                                              'Payslip YTD',
                                                              'Payslip Leave',
                                                              'Payslip BRP',
                                                              'Payslip GRP Leave',
                                                              'Payment ID',
                                                              'Payslip Basic Rate' )	----NH ZA-1124836
            INNER JOIN [Output Transactions] OT WITH ( NOLOCK ) ON OT.[Resource Tag] = SE.[Resource Tag]
                                                              AND OT.[Period ID] = SE.[Period Id]
                                                              AND OT.[Element] = EDP.[Column 1 Element]
                                                              AND OT.[Back Pay] != 'Yes'
----Start NH ZA-1124836
-- RS No ZA-2107019
--Heat 9428
--LEFT OUTER JOIN	[Output Transactions]		OT2	WITH (NOLOCK)
--							ON	OT2.[Resource Tag]	=	SE.[Resource Tag]
--							AND	OT2.[Period ID]		=	SE.[Period ID]
--							AND	OT2.[Element]		=	'Payment ID'
            INNER JOIN [Payment ID Control] PIC WITH ( NOLOCK ) ON PIC.[Payment ID Value] = SE.[Payment ID]
                                                              AND PIC.[Payment ID] LIKE @PaymentID;
							
    IF @PaymentID = '%'
        AND @Resource_Tag = '%'
        BEGIN
            DELETE  FROM #OT
            WHERE   [Payment ID] LIKE '%GRP-DE%';
        END;
--End NH ZA-1124836

-- select '#ot'		
-- select * from #ot	
-- order by [element]	
			
-- Sorting out the YTD info --
    SELECT  OT.[Resource Tag] ,
            OT.[Period ID] ,
            EDP.[Item Description] AS [YTD Line Description] ,
            EDP.[Sequence] AS [Sequence] ,
            0 AS [New Sequence] ,
            OT.[Output Value] AS [YTD Balance]
    INTO    #YTD_Old
    FROM    [Element Document Parameters] EDP WITH ( NOLOCK )
            INNER JOIN #OT OT ON EDP.[Document] = 'Payslip YTD'
                                 AND EDP.[Column 1 Element] = OT.[Element]
    WHERE   OT.[Output Value] != 0
    ORDER BY OT.[Resource Tag] ,
            OT.[Period ID] ,
            EDP.[Sequence];

    CREATE NONCLUSTERED INDEX [YTD_Old] ON  #YTD_Old ---SYM47509
    (
    [Resource Tag] ASC,
    [Period ID] ASC,
    [Sequence] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90);

-- 
-- select '#YTD_Old'
-- select * from #YTD_Old

    DECLARE @Count INT;
    DECLARE @Seq INT;
    DECLARE @PrevSeq INT;
    SET @Count = 0;
    SET @PrevSeq = 0;

    UPDATE  #YTD_Old
    SET     @Seq = [Sequence] ,
            @Count = [New Sequence] = ( CASE WHEN @Seq < @PrevSeq THEN 0
                                             ELSE CASE WHEN @Seq = @PrevSeq
                                                       THEN 0
                                                       ELSE @Count
                                                  END
                                        END ) + 1 ,
            @PrevSeq = [Sequence];

    CREATE TABLE #YTD
        (
          [Resource Tag] INT NOT NULL ,
          [Period ID] INT NOT NULL ,
          [YTD Description 1] VARCHAR(50) NULL ,
          [YTD Balance 1] DECIMAL(18, 2) NULL ,
          [YTD Description 2] VARCHAR(50) NULL ,
          [YTD Balance 2] DECIMAL(18, 2) NULL ,
          [YTD Description 3] VARCHAR(50) NULL ,
          [YTD Balance 3] DECIMAL(18, 2) NULL ,
          [YTD Description 4] VARCHAR(50) NULL ,
          [YTD Balance 4] DECIMAL(18, 2) NULL ,
          [YTD Description 5] VARCHAR(50) NULL ,
          [YTD Balance 5] DECIMAL(18, 2) NULL ,
          [YTD Description 6] VARCHAR(50) NULL ,
          [YTD Balance 6] DECIMAL(18, 2) NULL ,
          [YTD Description 7] VARCHAR(50) NULL ,
          [YTD Balance 7] DECIMAL(18, 2) NULL ,
          [YTD Description 8] VARCHAR(50) NULL ,
          [YTD Balance 8] DECIMAL(18, 2) NULL ,
          [YTD Description 9] VARCHAR(50) NULL ,
          [YTD Balance 9] DECIMAL(18, 2) NULL ,
          [YTD Description 10] VARCHAR(50) NULL ,
          [YTD Balance 10] DECIMAL(18, 2) NULL ,
          [YTD Description 11] VARCHAR(50) NULL ,
          [YTD Balance 11] DECIMAL(18, 2) NULL ,
          [YTD Description 12] VARCHAR(50) NULL ,
          [YTD Balance 12] DECIMAL(18, 2) NULL ,
          [YTD Description 13] VARCHAR(50) NULL ,
          [YTD Balance 13] DECIMAL(18, 2) NULL ,
          [YTD Description 14] VARCHAR(50) NULL ,
          [YTD Balance 14] DECIMAL(18, 2) NULL ,
          [YTD Description 15] VARCHAR(50) NULL ,
          [YTD Balance 15] DECIMAL(18, 2) NULL ,
          [YTD Description 16] VARCHAR(50) NULL ,
          [YTD Balance 16] DECIMAL(18, 2) NULL ,
          [YTD Description 17] VARCHAR(50) NULL ,
          [YTD Balance 17] DECIMAL(18, 2) NULL ,
          [YTD Description 18] VARCHAR(50) NULL ,
          [YTD Balance 18] DECIMAL(18, 2) NULL ,
          [YTD Description 19] VARCHAR(50) NULL ,
          [YTD Balance 19] DECIMAL(18, 2) NULL ,
          [YTD Description 20] VARCHAR(50) NULL ,
          [YTD Balance 20] DECIMAL(18, 2) NULL ,
-- Issue 1396189 PVCS vs 2.1 Start of Change
          [YTD Description 21] VARCHAR(50) NULL ,
          [YTD Balance 21] DECIMAL(18, 2) NULL ,
          [YTD Description 22] VARCHAR(50) NULL ,
          [YTD Balance 22] DECIMAL(18, 2) NULL ,
          [YTD Description 23] VARCHAR(50) NULL ,
          [YTD Balance 23] DECIMAL(18, 2) NULL ,
          [YTD Description 24] VARCHAR(50) NULL ,
          [YTD Balance 24] DECIMAL(18, 2) NULL ,
          [YTD Description 25] VARCHAR(50) NULL ,
          [YTD Balance 25] DECIMAL(18, 2) NULL
-- Issue 1396189 PVCS vs 2.1 End of Change
        );

-- DECLARE	@SQL	VARCHAR(4000)		-- Issue 1396189 PVCS vs 2.1 remove
    DECLARE @SQL VARCHAR(5000);			-- Issue 1396189 PVCS vs 2.1 Add
    DECLARE @ECount INT;
    SET @SQL = 'INSERT INTO #YTD' + CHAR(10) + 'SELECT	[Resource Tag],'
        + CHAR(10) + '	[Period ID]';
-- SET	@ECount =	20			-- Issue 1396189 PVCS vs 2.1 remove
    SET @ECount = 25;			-- Issue 1396189 PVCS vs 2.1 Add
    SET @Count = 1;

    WHILE @Count <= @ECount
        BEGIN
            SELECT  @SQL = @SQL + ',' + CHAR(10)
                    + '	MAX(CASE [New Sequence] WHEN '''
                    + CONVERT(VARCHAR, @Count)
                    + ''' THEN [YTD Line Description] ELSE NULL END) AS [YTD Description '
                    + CONVERT(VARCHAR, @Count) + ']' + ',' + CHAR(10)
                    + '	MAX(CASE [New Sequence] WHEN '''
                    + CONVERT(VARCHAR, @Count)
                    + ''' THEN [YTD Balance] ELSE NULL END) AS [YTD Balance '
                    + CONVERT(VARCHAR, @Count) + ']';

            SET @Count = @Count + 1;
        END;

    SET @SQL = @SQL + CHAR(10) + 'FROM #YTD_Old' + CHAR(10) + 'GROUP BY'
        + CHAR(10) + '	[Resource Tag],' + CHAR(10) + '	[Period ID]';

    EXEC (@SQL);

-- select '#YTD'
-- select * from #YTD

-- Sorting out the Leave info --
    SELECT  OT.[Resource Tag] ,
            OT.[Period ID] ,
            EDP.[Item Description] AS [Leave Line Description] ,
            EDP.[Sequence] AS [Sequence] ,
            0 AS [New Sequence] ,
            OT.[Output Value] AS [Leave Balance]
    INTO    #Leave_Old
    FROM    [Element Document Parameters] EDP WITH ( NOLOCK )
            INNER JOIN #OT OT ON EDP.[Document] = 'Payslip Leave'
                                 AND EDP.[Column 1 Element] = OT.[Element]
    WHERE   OT.[Output Value] != 0
    ORDER BY OT.[Resource Tag] ,
            OT.[Period ID] ,
            EDP.[Sequence];

    CREATE NONCLUSTERED INDEX [Leave_old] ON #Leave_Old   --SYM47509
    (
    [Resource Tag] ASC,
    [Period ID] ASC,
    [Sequence] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90);


-- select '#Leave_Old'
-- select * from #Leave_Old

    SET @Count = 0;
    SET @PrevSeq = 0;

    UPDATE  #Leave_Old
    SET     @Seq = [Sequence] ,
            @Count = [New Sequence] = ( CASE WHEN @Seq < 99
                                             THEN ( CASE WHEN @Seq < @PrevSeq
                                                         THEN 0
                                                         ELSE CASE
                                                              WHEN @Seq = @PrevSeq
                                                              THEN 0
                                                              ELSE @Count
                                                              END
                                                    END ) + 1
                                             ELSE @Seq
                                        END ) ,
            @PrevSeq = [Sequence];
--select '#Leave_Old',* from #Leave_Old --where [sequence] = 4

    CREATE TABLE #Leave
        (
          [Resource Tag] INT NOT NULL ,
          [Period ID] INT NOT NULL ,
          [Leave Description 1] VARCHAR(50) NULL ,
          [Leave Balance 1] DECIMAL(18, 3) NULL ,
          [Leave Description 2] VARCHAR(50) NULL ,
          [Leave Balance 2] DECIMAL(18, 3) NULL ,
          [Leave Description 3] VARCHAR(50) NULL ,
          [Leave Balance 3] DECIMAL(18, 3) NULL ,
          [Leave Description 4] VARCHAR(50) NULL ,
          [Leave Balance 4] DECIMAL(18, 3) NULL ,
          [Leave Description 5] VARCHAR(50) NULL ,
          [Leave Balance 5] DECIMAL(18, 3) NULL ,
          [Leave Description 6] VARCHAR(50) NULL ,
          [Leave Balance 6] DECIMAL(18, 2) NULL ,
          [Leave Description 7] VARCHAR(50) NULL ,
          [Leave Balance 7] DECIMAL(18, 3) NULL ,
          [Leave Description 8] VARCHAR(50) NULL ,
          [Leave Balance 8] DECIMAL(18, 3) NULL ,
          [Leave Description 9] VARCHAR(50) NULL ,
          [Leave Balance 9] DECIMAL(18, 3) NULL ,
          [Leave Description 10] VARCHAR(50) NULL ,
          [Leave Balance 10] DECIMAL(18, 3) NULL ,
          [Leave Description 11] VARCHAR(50) NULL ,
          [Leave Balance 11] DECIMAL(18, 3) NULL
        );

    SET @SQL = 'INSERT INTO #Leave' + CHAR(10) + 'SELECT	[Resource Tag],'
        + CHAR(10) + '	[Period ID]';
    SET @ECount = 11;
    SET @Count = 1;

    WHILE @Count <= @ECount
        BEGIN
            SELECT  @SQL = @SQL + ',' + CHAR(10)
                    + '	MAX(CASE [New Sequence] WHEN '''
                    + CONVERT(VARCHAR, @Count)
                    + ''' THEN [Leave Line Description] ELSE NULL END) AS [Leave Description '
                    + CONVERT(VARCHAR, @Count) + ']' + ',' + CHAR(10)
                    + '	MAX(CASE [New Sequence] WHEN '''
                    + CONVERT(VARCHAR, @Count)
                    + ''' THEN [Leave Balance] ELSE NULL END) AS [Leave Balance '
                    + CONVERT(VARCHAR, @Count) + ']';

            SET @Count = @Count + 1;
        END;

    SET @SQL = @SQL + CHAR(10) + 'FROM #Leave_Old' + CHAR(10)
        + 'WHERE [Sequence] != 99 ' + CHAR(10) + 'GROUP BY' + CHAR(10)
        + '	[Resource Tag],' + CHAR(10) + '	[Period ID]';

    EXEC (@SQL);


-- select '#Leave'
-- select * from #Leave

-- Sorting out the Basic Rate info --
    CREATE TABLE #BR_Old
        (
          [Resource Tag] INT NOT NULL ,
          [Period ID] INT NOT NULL ,
          [Basic Rate Line Description] NVARCHAR(50) NULL ,
          [Sequence] INT NOT NULL ,
          [New Sequence] INT NULL ,
          [Value] DECIMAL(18, 2) NULL
        );

--ALTER TABLE #BR_Old ADD CONSTRAINT
--	#PK_BR_Old PRIMARY KEY CLUSTERED 
--	(
--	[Resource Tag],
--	[Period ID],
--	Sequence
--	) ON [PRIMARY]

    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Standard Rate' ,
                    1 ,
                    0 ,
--ISNULL((EC.[Rate of Pay] + ISNULL(EC.[Rate Adj Amount],0)),(ISNULL(EC.[Rate Adj Amount],0) + CASE WHEN ENC.[Resource Tag] IS NULL THEN GDC.[Minimum Rate] ELSE GDC.[Novice Rate] END ))  --SYM38472
--CASE WHEN ec.[resource tag] IS NULL THEN ( CASE WHEN ENC.[Resource Tag] IS NULL THEN GDC.[Minimum Rate] ELSE GDC.[Novice Rate] END ) ELSE EC.[Rate of Pay] END
                    COALESCE( EBC.[SROP],ISNULL(( EC.[Rate of Pay] ),
                           ( CASE WHEN ENC.[Resource Tag] IS NULL
                                  THEN GDC.[Minimum Rate]
                                  ELSE GDC.[Novice Rate]
                             END )))
            FROM    #SE SE
			INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Grp Designation Control] GDC WITH ( NOLOCK ) ON GDC.[Designation] = SE.[Designation]
                                                              AND GDC.[Operation] = SE.[Operation]
                                                              AND GDC.[Start Date] <= SE.[Cal End Date]
                                                              AND GDC.[End Date] >= SE.[Cal End Date]
                    LEFT OUTER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                    LEFT OUTER JOIN [dbo].[Emp Novice Control] ENC WITH ( NOLOCK ) ON ENC.[Resource Tag] = SE.[Resource Tag]
                                                              AND ENC.[Start Date] <= SE.[Cal End Date]
                                                              AND ENC.[End Date] >= SE.[Cal End Date]
															  
															  LEFT OUTER JOIN [dbo].[Emp_Brop_Control_Header] AS EBC WITH ( NOLOCK ) ON EBC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EBC.[Start Date] <= SE.[Cal End Date]
                                                              AND EBC.[End Date] >= SE.[Cal End Date];;

    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Service Increment' ,
                    2 ,
                    0 ,
		--ETD.[Service Increment]
                    CASE WHEN ETD.Acting = 'Yes'
                         THEN ETD.[From Service Increment]
                         ELSE ETD.[Service Increment]
                    END  --SYM50765
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Emp TA Detail] ETD WITH ( NOLOCK ) ON ETD.[Resource Tag] = SE.[Resource Tag]
                                                              AND ETD.[Date] = COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date]);


        INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'INC 2014' ,			-- HEAT-4364 'Rate Make-Up',
                    3 ,							-- HEAT-4364 3,
                    0 ,
                    [Value]
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [dbo].[Emp_Brop_Control_Header] AS EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
															  INNER JOIN [dbo].[Emp_Brop_Control_Detail] AS [ebcd] ON ebcd.ID = EC.ID
															  AND ebcd.Element = 'INC 2014';  
  
        INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'INC 2015' ,			-- HEAT-4364 'Rate Make-Up',
                    4 ,							-- HEAT-4364 3,
                    0 ,
                    [Value]
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [dbo].[Emp_Brop_Control_Header] AS EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
															  INNER JOIN [dbo].[Emp_Brop_Control_Detail] AS [ebcd] ON ebcd.ID = EC.ID
															  AND ebcd.Element = 'INC 2015';  


															    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'INC 2016' ,			-- HEAT-4364 'Rate Make-Up',
                    5 ,							-- HEAT-4364 3,
                    0 ,
                    [Value]
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [dbo].[Emp_Brop_Control_Header] AS EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
															  INNER JOIN [dbo].[Emp_Brop_Control_Detail] AS [ebcd] ON ebcd.ID = EC.ID
															  AND ebcd.Element = 'INC 2016';  



--SYM38472 add Rate Adj Amount seperately called Consolidated Amt
    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Consolidated Amt' ,			-- HEAT-4364 'Rate Make-Up',
                    3 ,							-- HEAT-4364 3,
                    0 ,
                    ISNULL(EC.[Rate Adj Amount], 0)
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date]);


--SYM38472 add Rate Make-Up seperately called Variance Amount

    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Variance Amount' ,			-- HEAT-4364 'Rate Make-Up',
                    4 ,							-- HEAT-4364 3,
                    0 ,
                    ISNULL(EC.[Rate Make-up], 0)
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date]);


-- HEAT-4364 Add all values from Emp Control that affect Rate into Standard Rate
--
--INSERT INTO #BR_Old    ---SYM38472
--SELECT	SE.[Resource Tag],
--		SE.[Period ID],
--		'Standard Rate',			-- HEAT-4364 'Rate Make-Up',
--		1,							-- HEAT-4364 3,
--		0,
--		ISNULL(EC.[Rate Make-Up],0)
--FROM			#SE							SE
--INNER JOIN		[Emp Control]				EC	WITH (NOLOCK)
--												ON	EC.[Resource Tag]	=	SE.[Resource Tag]
--												AND	EC.[Start Date]		<=	SE.[Cal End Date]
--												AND	EC.[End Date]		>=	SE.[Cal End Date]
    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Standard Rate' ,			-- HEAT-4364 'Artisan Bonus',
                    1 ,							-- HEAT-4364 4,
                    0 ,
                    ISNULL(EC.[Artisan Bonus], 0)
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date]);
    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Standard Rate' ,			-- HEAT-4364 'Prefunding',
                    1 ,							-- HEAT-4364 5,
                    0 ,
                    ISNULL(EC.[Prefunding], 0)
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date]);
    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Standard Rate' ,			-- HEAT-4364 'TM3 Make-Up',
                    1 ,							-- HEAT-4364 6,
                    0 ,
                    ISNULL(EC.[TM3 make-up], 0)
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date]);
    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Standard Rate' ,			-- HEAT-4364 'Winding Engine Driver Relief Allowance',
                    1 ,							-- HEAT-4364 7,
                    0 ,
                    ( ISNULL(EC.[Rate of Pay],
                             ( ISNULL(EC.[Rate Adj Amount], 0)
                               + GDC.[Minimum Rate] ))
                      * GDC.[Winding Engine Driver Relief Allowance] ) / 100
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Grp Designation Control] GDC WITH ( NOLOCK ) ON GDC.[Designation] = SE.[Designation]
                                                              AND GDC.[Operation] = SE.[Operation]
                                                              AND GDC.[Start Date] <= SE.[Cal End Date]
                                                              AND GDC.[End Date] >= SE.[Cal End Date]
                                                              AND GDC.[Operation] = 'South Deep'
                    LEFT OUTER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
            WHERE   ISNULL(( ISNULL(EC.[Rate of Pay],
                                    ( ISNULL(EC.[Rate Adj Amount], 0)
                                      + GDC.[Minimum Rate] ))
                             * GDC.[Winding Engine Driver Relief Allowance] )
                           / 100, 0) != 0;



    INSERT  INTO #BR_Old
            SELECT  SE.[Resource Tag] ,
                    SE.[Period Id] ,
                    'Premium Amount' ,			-- HEAT-4364 'Winding Engine Driver Relief Allowance',
                    5 ,							-- HEAT-4364 7,
                    0 ,
		--ISNULL(GDC.[Premium],0)
		--CASE WHEN ISNULL([EC].[Employee Status], '') = 'Temporary Employee'  THEN 0.00 ELSE ISNULL(GDC.[Premium],0) END
                    CASE WHEN SE.[Cal End Date] <= '09-may-2016' THEN 0.00
                         ELSE CASE WHEN ISNULL([EC].[Employee Status], '') = 'Temporary Employee'
                                   THEN 0.00
                                   ELSE ISNULL(GDC.[Premium], 0)
                              END
                    END  ---SYM55876
            FROM    #SE SE INNER JOIN #Header_Footer AS hf ON hf.[Resource Tag] = SE.[Resource Tag] AND hf.[Period Id] = SE.[Period Id]
                    INNER JOIN [Grp Designation Control] GDC WITH ( NOLOCK ) ON GDC.[Designation] = SE.[Designation]
                                                              AND GDC.[Operation] = SE.[Operation]
                                                              AND GDC.[Start Date] <= SE.[Cal End Date]
                                                              AND GDC.[End Date] >= SE.[Cal End Date]
                    LEFT OUTER JOIN [Emp Control] EC WITH ( NOLOCK ) ON EC.[Resource Tag] = SE.[Resource Tag]
                                                              AND EC.[Start Date] <= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
                                                              AND EC.[End Date] >= COALESCE(NULLIF(hf.[Termination Date],'99991231'),SE.[Cal End Date])
            WHERE   GDC.[Premium] > 0;



    INSERT  INTO #BR_Old
            SELECT  OT.[Resource Tag] ,
                    OT.[Period ID] ,
                    'Standard Rate' ,			-- HEAT-4364  -- EDP.[Item Description]		AS	[Basic Rate Line Description], -- HEAT-4364
                    1 ,							-- HEAT-4364 EDP.[Sequence]				AS	[Sequence],
                    0 AS [New Sequence] ,
                    SUM(OT.[Output Value]) AS [Value] -- HEAT-4364 - Add Sum in case more elements added to Element Document Parameters for Payslip Basic Rate
            FROM    [Element Document Parameters] EDP WITH ( NOLOCK )
                    INNER JOIN #OT OT ON EDP.[Document] = 'Payslip Basic Rate'
                                         AND EDP.[Column 1 Element] = OT.[Element]
            WHERE   ISNULL(OT.[Output Value], 0) != 0
            GROUP BY						-- HEAT-4364 Add Sum in case more elements added to Element Document Parameters for Payslip Basic Rate
                    OT.[Resource Tag] ,
                    OT.[Period ID]
            ORDER BY OT.[Resource Tag] ,
                    OT.[Period ID];				-- HEAT-4364,
								-- HEAT-4364	EDP.[Sequence]


/*INSERT INTO #BR_Old
SELECT	SE.[Resource Tag],
		SE.[Period ID],
		'Underground Allowance',
		8,
		0,
		SUM(ETD.[SD Underground Allowance])
FROM			#SE							SE
INNER JOIN		[Calendar Periods]			CP	WITH (NOLOCK)
												ON	CP.[Period ID]		=	SE.[Period ID]
INNER JOIN		[Emp TA Detail]				ETD	WITH (NOLOCK)
												ON	ETD.[Resource Tag]	=	SE.[Resource Tag]
												AND	ETD.[Date]			<=	CP.[End Date]
												AND	ETD.[Date]			>=	CP.[Start Date]
GROUP BY
		SE.[Resource Tag],
		SE.[Period ID]
*/
    INSERT  INTO #BR_Old
            SELECT  [Resource Tag] ,
                    [Period ID] ,
                    'Total Basic Rate' ,
                    9 ,
                    0 ,
                    SUM([Value])
            FROM    #BR_Old
            GROUP BY [Resource Tag] ,
                    [Period ID];

    DELETE  FROM #BR_Old
    WHERE   [Value] = 0;

    SET @Count = 0;
    SET @PrevSeq = 0;

    SELECT  [Resource Tag] ,
            [Period ID] ,
            [Basic Rate Line Description] ,
            [Sequence] ,
            [New Sequence] ,
            SUM([Value]) AS [Value]			-- HEAT-4364
    INTO    #BR2
    FROM    #BR_Old
    GROUP BY								-- HEAT-4364
            [Resource Tag] ,
            [Period ID] ,
            [Basic Rate Line Description] ,
            [Sequence] ,
            [New Sequence]
    ORDER BY [Resource Tag] ,
            [Period ID] ,
            [Sequence];

    CREATE NONCLUSTERED INDEX [BR2] ON  #BR2  --SYM47509
    (
    [Resource Tag] ASC,
    [Period ID] ASC,
    [Sequence] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90);


--select '#BR_Old',* FROM #BR_Old
--select '#BR2',* FROM #BR2

    UPDATE  BR
    SET     @Seq = [Sequence] ,
            @Count = [New Sequence] = ( CASE WHEN @Seq < 99
                                             THEN ( CASE WHEN @Seq < @PrevSeq
                                                         THEN 0
                                                         ELSE CASE
                                                              WHEN @Seq = @PrevSeq
                                                              THEN 0
                                                              ELSE @Count
                                                              END
                                                    END ) + 1
                                             ELSE @Seq
                                        END ) ,
            @PrevSeq = [Sequence]
    FROM    #BR2 BR;

--select '#BR2',* from #BR2

    CREATE TABLE #BR
        (
          [Resource Tag] INT NOT NULL ,
          [Period ID] INT NOT NULL ,
          [BR Description 1] VARCHAR(50) NULL ,
          [BR Balance 1] DECIMAL(18, 2) NULL ,
          [BR Description 2] VARCHAR(50) NULL ,
          [BR Balance 2] DECIMAL(18, 2) NULL ,
          [BR Description 3] VARCHAR(50) NULL ,
          [BR Balance 3] DECIMAL(18, 2) NULL ,
          [BR Description 4] VARCHAR(50) NULL ,
          [BR Balance 4] DECIMAL(18, 2) NULL ,
          [BR Description 5] VARCHAR(50) NULL ,
          [BR Balance 5] DECIMAL(18, 2) NULL ,
          [BR Description 6] VARCHAR(50) NULL ,
          [BR Balance 6] DECIMAL(18, 2) NULL ,
          [BR Description 7] VARCHAR(50) NULL ,
          [BR Balance 7] DECIMAL(18, 2) NULL ,
          [BR Description 8] VARCHAR(50) NULL ,
          [BR Balance 8] DECIMAL(18, 2) NULL ,
          [BR Description 9] VARCHAR(50) NULL ,
          [BR Balance 9] DECIMAL(18, 2) NULL
        );

    SET @SQL = 'INSERT INTO #BR' + CHAR(10) + 'SELECT	[Resource Tag],'
        + CHAR(10) + '	[Period ID]';
    SET @ECount = 9;
    SET @Count = 1;

    WHILE @Count <= @ECount
        BEGIN
            SELECT  @SQL = @SQL + ',' + CHAR(10)
                    + '	MAX(CASE [New Sequence] WHEN '''
                    + CONVERT(VARCHAR, @Count)
                    + ''' THEN [Basic Rate Line Description] ELSE NULL END) AS [Basic Rate Description '
                    + CONVERT(VARCHAR, @Count) + ']' + ',' + CHAR(10)
                    + '	MAX(CASE [New Sequence] WHEN '''
                    + CONVERT(VARCHAR, @Count)
                    + ''' THEN [Value] ELSE NULL END) AS [Value '
                    + CONVERT(VARCHAR, @Count) + ']';

            SET @Count = @Count + 1;
        END;

    SET @SQL = @SQL + CHAR(10) + 'FROM #BR2' + CHAR(10)
        + 'WHERE [Sequence] != 99 ' + CHAR(10) + 'GROUP BY' + CHAR(10)
        + '	[Resource Tag],' + CHAR(10) + '	[Period ID]';

    EXEC (@SQL);

--select '#BR',* from #BR

/********--Start NH ZA-1124836********/
    SELECT  T1.* ,
-- 	convert(varchar(11),dateadd(yy,1,(T2.[End Date] + T1.[Leave Balance])),106)
-- 			AS	'Leave Due Date MAX',
            CONVERT(VARCHAR(11), ( DATEADD(dd, -1,
                                           CONVERT(DATETIME, ( '01-'
                                                              + CONVERT(VARCHAR(3), DATENAME(mm,
                                                              DATEADD(mm, 1,
                                                              ( DATEADD(yy, 1,
                                                              ( T2.[End Date]
                                                              + T1.[Leave Balance] )) ))), 106)
                                                              + '-'
                                                              + CONVERT(VARCHAR(4), DATEPART(yy,
                                                              ( DATEADD(yy, 1,
                                                              ( T2.[End Date]
                                                              + T1.[Leave Balance] )) )), 106) ))) ), 106) AS 'Leave Due Date MAX' ,
--	convert(varchar(11),EAR.[Start Date],106)	AS [Actual Leave Date],
            EAR.[Number of Days] AS [Number of Days]
    INTO    #Leave_Dates
    FROM    #Leave_Old T1
            INNER JOIN #Calendar T2 ON T2.[Period ID] = T1.[Period ID]
                                       AND T2.[RunType] = 'Normal'
            LEFT OUTER JOIN [Emp Absence Request] EAR WITH ( NOLOCK ) ON EAR.[Resource Tag] = T1.[Resource Tag]
                                                              AND EAR.[Pay Date] > @DateTo
                                                              AND EAR.[Status] = 'Leave Completed'
                                                              AND ( EAR.[Absence Transaction] LIKE '%Annual Leave%'
															        OR
                                                                    EAR.[Absence Transaction] LIKE '%Statutory Leave%')
    WHERE   T1.[Sequence] IN ( 4, 99 );

-- select '#Leave_Dates'
-- select * from #Leave_Dates

-- Sorting out the Remuneration Package info --
    SELECT  HF.[Resource Tag] ,
            HF.[Period Id] ,
            HF.[Payment ID] ,
            MAX(PRP.[End Date]) AS [End Date]
    INTO    #LatestPLT
    FROM    #Header_Footer HF
            LEFT OUTER JOIN [dbo].[Per Rem Package PLT] AS PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = HF.[Resource Tag]
                                                              AND PRP.[Start Date] <= CONVERT(DATETIME, LEFT(HF.[Period Id],
                                                              8))
    GROUP BY HF.[Resource Tag] ,
            HF.[Period Id] ,
            HF.[Payment ID];

-- select '#LatestPLT'
-- select * from #LatestPLT

    SELECT  L.[Resource Tag] ,
            L.[Period Id] ,
            L.[Payment ID] ,
            MAX(PRP.[End Date]) AS [End Date]
    INTO    #PreviousPLT
    FROM    #LatestPLT L
            LEFT OUTER JOIN [Per Rem Package PLT] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = L.[Resource Tag]
                                                              AND PRP.[Start Date] <= CONVERT(DATETIME, LEFT(L.[Period Id],
                                                              8))
                                                              AND PRP.[End Date] <> L.[End Date]
    GROUP BY L.[Resource Tag] ,
            L.[Period Id] ,
            L.[Payment ID];

-- select '#PreviousPLT'
-- select * from  #PreviousPLT

    SELECT  HF.[Resource Tag] ,
            HF.[Period Id] ,
            HF.[Payment ID] ,
            MAX(PRP.[End Date]) AS [End Date]
    INTO    #Latest
    FROM    #Header_Footer HF
            LEFT OUTER JOIN [PER REM Package] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = HF.[Resource Tag]
                                                              AND PRP.[Start Date] <= CONVERT(DATETIME, LEFT(HF.[Period Id],
                                                              8))
    WHERE   PRP.[ARMS Process Status] = 'Authorised'
    GROUP BY HF.[Resource Tag] ,
            HF.[Period Id] ,
            HF.[Payment ID];

-- select '#Latest'
-- select * from #Latest

    SELECT  L.[Resource Tag] ,
            L.[Period Id] ,
            L.[Payment ID] ,
            MAX(PRP.[End Date]) AS [End Date]
    INTO    #Previous
    FROM    #Latest L
            LEFT OUTER JOIN [PER REM Package] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = L.[Resource Tag]
                                                              AND PRP.[Start Date] <= CONVERT(DATETIME, LEFT(L.[Period Id],
                                                              8))
                                                              AND PRP.[End Date] <> L.[End Date]
    WHERE   PRP.[ARMS Process Status] = 'Authorised'
    GROUP BY L.[Resource Tag] ,
            L.[Period Id] ,
            L.[Payment ID];

-- select '#Previous'
-- select * from #Previous

    SELECT  L.[Resource Tag] ,
            L.[Period Id] ,
            PRP.[Start Date] ,
            PRP.[End Date] ,
            L.[Payment ID] ,
            PRP.[Gross Remuneration Package (Annual)] ,
            PRP.[Gross Remuneration Package (Monthly)] ,
            PRP.[Individual Gross Remuneration Package (Annual)] AS [Indiv Gross Rem Package (Annual)] ,
            PRP.[Individual Gross Remuneration Package (Monthly)] AS [Indiv Gross Rem Package (Monthly)] ,
            PRP.[Pensionable Gross Remuneration Package (Annual)] ,
            PRP.[Pensionable Gross Remuneration Package (Monthly)] ,
            PRP.[Pensionable Emoluments (Annual)] ,
            PRP.[Pensionable Emoluments (Monthly)] ,
            PRP.[Pensionable Emoluments Percentage of GRP] AS [Pension Emolument Percentage] ,
            CASE PRP.[Retirement Fund]
              WHEN 'Sentinel (Post Mar 01)' THEN 'Sentinel'
              ELSE PRP.[Retirement Fund]
            END AS [Retirement Fund] ,
            PRP.[Retirement Option] ,
            PRP.[Total Employer Contribution (Annual)] AS [Retirement (Annual)] ,
            PRP.[Total Employer Contribution (Monthly)] AS [Retirement (Monthly)] ,
            PRP.[Medical Fund] ,
            PRP.[Medical Fund Option] ,
            PRP.[Medical Fund Value (Annual)] ,
            PRP.[Medical Fund Value (Monthly)] ,
            PRP.[Additional Annual Leave Days (Annual)] AS [Addit Ann Leave Days (Annual)] ,
            PRP.[Additional Annual Leave Days (Monthly)] AS [Addit Ann Leave Days (Monthly)] ,
            PRP.[Additional Annual Leave Value (Annual)] AS [Addit Ann Leave Value (Annual)] ,
            PRP.[Additional Annual Leave Value (Monthly)] AS [Addit Ann Leave Value (Monthly)] ,
            PRP.[Car Allowance Amount (Annual)] ,
            PRP.[Car Allowance Amount (Monthly)] ,
            PRP.[Benefit Value (Annual)] ,
            PRP.[Benefit Value (Monthly)] ,
            PRP.[Cash Component (Annual)] ,
            PRP.[Cash Component (Monthly)] ,
            PRP.[ARMS Process Status] ,
            PRP.[HLA Percentage] ,															--NH ZA-1124836
            PRP.[Housing Deduction Amount] AS [House Ded (Mth)] ,		--NH ZA-1124836
            PRP.[Housing Deduction Amount (Annual)] AS [House Ded (Ann)] ,		--NH ZA-1124836
            CASE WHEN [BR Description 1] = 'Premium Amount'
                 THEN [BR Balance 1]
                 WHEN [BR Description 2] = 'Premium Amount'
                 THEN [BR Balance 2]
                 WHEN [BR Description 3] = 'Premium Amount'
                 THEN [BR Balance 3]
                 WHEN [BR Description 4] = 'Premium Amount'
                 THEN [BR Balance 4]
                 WHEN [BR Description 5] = 'Premium Amount'
                 THEN [BR Balance 5]
                 WHEN [BR Description 6] = 'Premium Amount'
                 THEN [BR Balance 6]
                 WHEN [BR Description 7] = 'Premium Amount'
                 THEN [BR Balance 7]
                 WHEN [BR Description 8] = 'Premium Amount'
                 THEN [BR Balance 8]
                 WHEN [BR Description 9] = 'Premium Amount'
                 THEN [BR Balance 9]
                 ELSE 0
            END AS [Premium amt]
    INTO    #REM_Latest
    FROM    #Latest L
            LEFT OUTER JOIN [PER REM Package] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = L.[Resource Tag]
                                                              AND PRP.[End Date] = L.[End Date]
            LEFT OUTER JOIN #BR AS BR WITH ( NOLOCK ) ON BR.[Resource Tag] = L.[Resource Tag]
                                                         AND BR.[Period ID] = L.[Period Id];

-- select '#REM_Latest'
-- select * from #REM_Latest

    SELECT  P.[Resource Tag] ,
            P.[Period Id] ,
            PRP.[Start Date] ,
            PRP.[End Date] ,
            P.[Payment ID] ,
            PRP.[Gross Remuneration Package (Annual)] ,
            PRP.[Gross Remuneration Package (Monthly)] ,
            PRP.[Individual Gross Remuneration Package (Annual)] AS [Indiv Gross Rem Package (Annual)] ,
            PRP.[Individual Gross Remuneration Package (Monthly)] AS [Indiv Gross Rem Package (Monthly)] ,
            PRP.[Pensionable Gross Remuneration Package (Annual)] ,
            PRP.[Pensionable Gross Remuneration Package (Monthly)] ,
            PRP.[Pensionable Emoluments (Annual)] ,
            PRP.[Pensionable Emoluments (Monthly)] ,
            PRP.[Pensionable Emoluments Percentage of GRP] AS [Pension Emolument Percentage] ,
            CASE PRP.[Retirement Fund]
              WHEN 'Sentinel (Post Mar 01)' THEN 'Sentinel'
              ELSE PRP.[Retirement Fund]
            END AS [Retirement Fund] ,
            PRP.[Retirement Option] ,
            PRP.[Total Employer Contribution (Annual)] AS [Retirement (Annual)] ,
            PRP.[Total Employer Contribution (Monthly)] AS [Retirement (Monthly)] ,
            PRP.[Medical Fund] ,
            PRP.[Medical Fund Option] ,
            PRP.[Medical Fund Value (Annual)] ,
            PRP.[Medical Fund Value (Monthly)] ,
            PRP.[Additional Annual Leave Days (Annual)] AS [Addit Ann Leave Days (Annual)] ,
            PRP.[Additional Annual Leave Days (Monthly)] AS [Addit Ann Leave Days (Monthly)] ,
            PRP.[Additional Annual Leave Value (Annual)] AS [Addit Ann Leave Value (Annual)] ,
            PRP.[Additional Annual Leave Value (Monthly)] AS [Addit Ann Leave Value (Monthly)] ,
            PRP.[Car Allowance Amount (Annual)] ,
            PRP.[Car Allowance Amount (Monthly)] ,
            PRP.[Benefit Value (Annual)] ,
            PRP.[Benefit Value (Monthly)] ,
            PRP.[Cash Component (Annual)] ,
            PRP.[Cash Component (Monthly)] ,
            PRP.[ARMS Process Status] ,
            PRP.[HLA Percentage] ,															--NH ZA-1124836
            PRP.[Housing Deduction Amount] AS [House Ded (Mth)] ,		--NH ZA-1124836
            PRP.[Housing Deduction Amount (Annual)] AS [House Ded (Ann)] ,		--NH ZA-1124836
            CASE WHEN [BR Description 1] = 'Premium Amount'
                 THEN [BR Balance 1]
                 WHEN [BR Description 2] = 'Premium Amount'
                 THEN [BR Balance 2]
                 WHEN [BR Description 3] = 'Premium Amount'
                 THEN [BR Balance 3]
                 WHEN [BR Description 4] = 'Premium Amount'
                 THEN [BR Balance 4]
                 WHEN [BR Description 5] = 'Premium Amount'
                 THEN [BR Balance 5]
                 WHEN [BR Description 6] = 'Premium Amount'
                 THEN [BR Balance 6]
                 WHEN [BR Description 7] = 'Premium Amount'
                 THEN [BR Balance 7]
                 WHEN [BR Description 8] = 'Premium Amount'
                 THEN [BR Balance 8]
                 WHEN [BR Description 9] = 'Premium Amount'
                 THEN [BR Balance 9]
                 ELSE 0
            END AS [Premium amt]
    INTO    #REM_Previous
    FROM    #Previous P
            LEFT OUTER JOIN [PER REM Package] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = P.[Resource Tag]
                                                              AND PRP.[End Date] = P.[End Date]
            LEFT OUTER JOIN #BR AS BBR WITH ( NOLOCK ) ON BBR.[Resource Tag] = P.[Resource Tag]
                                                          AND BBR.[Period ID] = P.[Period Id];

---PLT Packages   ---SYM60927

    SELECT  L.[Resource Tag] ,
            L.[Period Id] ,
            PRP.[Start Date] ,
            PRP.[End Date] ,
            L.[Payment ID] ,
            PRP.[Basic Salary_Fixed] ,
            PRP.[Basic Salary_Fixed] * 12 AS [Basic Salary_Fixed_Ann] ,
            PRP.[Travel Allow_Fixed] ,
			PRP.[Travel Allow_Fixed] * 12 AS  [Travel Allow_Fixed_Ann],
            PRP.[13th Checque_Fixed] ,
			PRP.[13th Checque_Fixed] * 12 AS [13th Checque_Fixed_Ann],
            PRP.[CC PHI_Fixed] ,
			PRP.[CC PHI_Fixed] * 12 AS [CC PHI_Fixed_Ann],
            PRP.[App Package_Fixed] ,
			PRP.[App Package_Fixed] * 12 AS [App Package_Fixed_Ann],
            PRP.[Non Pens All_Fixed] ,
			PRP.[Non Pens All_Fixed] * 12 AS [Non Pens All_Fixed_Ann],
            PRP.[Transport All_Fixed] ,
			PRP.[Transport All_Fixed] * 12 AS [Transport All_Fixed_Ann],
            PRP.[Cell Phone All_Fixed] ,
			PRP.[Cell Phone All_Fixed] * 12 AS [Cell Phone All_Fixed_Ann],
            PRP.[CC Pension_Fixed] ,
			PRP.[CC Pension_Fixed] * 12 AS  [CC Pension_Fixed_Ann],
            PRP.[CC Risk_Fixed] ,
			PRP.[CC Risk_Fixed] * 12 AS [CC Risk_Fixed_Ann],
            PRP.[Other All_Fixed] ,
			PRP.[Other All_Fixed] * 12 AS [Other All_Fixed_Ann] ,
            PRP.[Vehicle Sacrify_Fixed] ,
			PRP.[Vehicle Sacrify_Fixed] * 12 AS [Vehicle Sacrify_Fixed_Ann] ,
            PRP.[Gross Package_Fixed],
			PRP.[Gross Package_Fixed] * 12 AS [Gross Package_Fixed_Ann]
    INTO    #REM_LatestPLT
    FROM    #LatestPLT L
            LEFT OUTER JOIN [dbo].[Per Rem Package PLT] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = L.[Resource Tag]
                                                              AND PRP.[End Date] = L.[End Date]
            LEFT OUTER JOIN #BR AS BR WITH ( NOLOCK ) ON BR.[Resource Tag] = L.[Resource Tag]
                                                         AND BR.[Period ID] = L.[Period Id];

-- select '#REM_LatestPLT'
-- select * from #REM_LatestPLT

    SELECT  P.[Resource Tag] ,
            P.[Period Id] ,
            PRP.[Start Date] ,
            PRP.[End Date] ,
            P.[Payment ID] ,
            PRP.[Basic Salary_Fixed] ,
			PRP.[Basic Salary_Fixed] * 12 AS [Basic Salary_Fixed_Ann],
            PRP.[Travel Allow_Fixed] ,
			PRP.[Travel Allow_Fixed] * 12 AS [Travel Allow_Fixed_Ann],
            PRP.[13th Checque_Fixed] ,
			PRP.[13th Checque_Fixed] * 12 AS  [13th Checque_Fixed_Ann],
            PRP.[CC PHI_Fixed] ,
			PRP.[CC PHI_Fixed] * 12 AS [CC PHI_Fixed_Ann],
            PRP.[App Package_Fixed] ,
			PRP.[App Package_Fixed] * 12 AS  [App Package_Fixed_Ann] ,
            PRP.[Non Pens All_Fixed] ,
			PRP.[Non Pens All_Fixed] * 12 AS [Non Pens All_Fixed_Ann],
            PRP.[Transport All_Fixed] ,
			PRP.[Transport All_Fixed] * 12 AS [Transport All_Fixed_Ann],
            PRP.[Cell Phone All_Fixed] ,
			PRP.[Cell Phone All_Fixed] * 12 AS [Cell Phone All_Fixed_Ann],
            PRP.[CC Pension_Fixed] ,
			PRP.[CC Pension_Fixed] * 12 AS [CC Pension_Fixed_Ann],
            PRP.[CC Risk_Fixed] ,
			PRP.[CC Risk_Fixed] * 12 AS [CC Risk_Fixed_Ann],
            PRP.[Other All_Fixed] ,
			PRP.[Other All_Fixed] * 12 AS [Other All_Fixed_Ann],
            PRP.[Vehicle Sacrify_Fixed] ,
			PRP.[Vehicle Sacrify_Fixed] * 12  AS [Vehicle Sacrify_Fixed_Ann],
            PRP.[Gross Package_Fixed],
			PRP.[Gross Package_Fixed] * 12 AS [Gross Package_Fixed_Ann]
    INTO    #REM_PreviousPLT
    FROM    #PreviousPLT P
            LEFT OUTER JOIN [Per Rem Package PLT] PRP WITH ( NOLOCK ) ON PRP.[Resource Tag] = P.[Resource Tag]
                                                              AND PRP.[End Date] = P.[End Date]
            LEFT OUTER JOIN #BR AS BBR WITH ( NOLOCK ) ON BBR.[Resource Tag] = P.[Resource Tag]
                                                          AND BBR.[Period ID] = P.[Period Id];

-- select '#REM_PreviousPLT'
-- select * from #REM_PreviousPLT

--- Gathering GRP Leave Info --
    SELECT DISTINCT
            OT.[Resource Tag] ,
            OT.[Period ID] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 1
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 46
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 47
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Opening Balance - Occ days] ,         
            SUM(ISNULL(CASE WHEN HF.[operation] NOT in ('Kroondal', 'Blue Ridge') 
			                     AND EDP.[Sequence] = 2 
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
			+  SUM(ISNULL(CASE WHEN HF.[operation]  in ('Kroondal', 'Blue Ridge') 
			                     AND EDP.[Sequence] = 37 
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 44
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Earned this month - Occ days] ,
            CASE WHEN HF.[Payment ID] = 'GRP-HO'
                 THEN ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 3
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 55
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0)) )
                 ELSE ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 3
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0)) )
            END AS [Adjustment - Occ days] ,
            CASE WHEN HF.[Payment ID] = 'GRP-HO'
                 THEN CONVERT(DECIMAL(18, 3), 0)
                      - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 55
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                 ELSE CONVERT(DECIMAL(18, 3), 0)
            END AS [Balance - Occ days] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 4
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Taken - Occ days] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 5
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 46
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Encashed - Occ days] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 6
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Closing Balance - Occ days] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 7
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Earned this month - Extra Occ days] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 37
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 44
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Earned this month - Tot Occ Days] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 8
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 48
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 49
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Opening Balance - Occ value] ,
            CONVERT(DECIMAL(18, 3), 0) AS [AVG Value/Day B/F - Occ value] ,
			CASE WHEN HF.[Payment ID] IN ( 'PLT-GRP-DE', 'PLT-GRP-Official')
                 THEN ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 37
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 44
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0)) )
                      * SUM(ISNULL(CASE WHEN EDP.[Sequence] = 9
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
									--END, 0)) *12/260   was for GRP-HO ( used this for PLT because of no Ho`s
                                   END, 0)) 
                 ELSE ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 37
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 44
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0)) )
                      * SUM(ISNULL(CASE WHEN EDP.[Sequence] = 9
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0)) * 12 / 365
            END AS [Earned this month - Occ value] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 10
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Adjustment - Occ value] ,
            CONVERT(DECIMAL(18, 3), 0) AS [Balance - Occ value] ,
            CONVERT(DECIMAL(18, 3), 0) AS [AVG Value/Day - Occ value] ,
            CONVERT(DECIMAL(18, 3), 0) AS [Taken - Occ value] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 11
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 45
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Encashed - Occ value] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 12
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Closing Balance - Occ value] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 13
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 32
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Opening Balance - Compulsory] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 14
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 42
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 33
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 43
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Earned this month - Compulsory] ,
	
	--ADDED GFL01704
            CASE WHEN HF.[Payment ID] = 'GRP-HO'
                 THEN ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 15
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 34
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0)) )
                      - ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 53
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                          + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 54
                                                 AND OT.[Element] = EDP.[Column 1 Element]
                                            THEN OT.[Output Value]
                                            ELSE 0
                                       END, 0)) )
                 ELSE SUM(ISNULL(CASE WHEN EDP.[Sequence] = 15
                                           AND OT.[Element] = EDP.[Column 1 Element]
                                      THEN OT.[Output Value]
                                      ELSE 0
                                 END, 0))
                      + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 34
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
            END AS [Adjustment - Compulsory] ,

	--ADDED GFL01704
            CASE WHEN HF.[Payment ID] = 'GRP-HO'
                 THEN ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 13
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 32
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 14
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 33
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 15
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 34
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 42
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 53
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 54
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 43
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0)) )
                 ELSE ( SUM(ISNULL(CASE WHEN EDP.[Sequence] = 13
                                             AND OT.[Element] = EDP.[Column 1 Element]
                                        THEN OT.[Output Value]
                                        ELSE 0
                                   END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 32
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 14
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 33
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 15
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 34
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 42
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0))
                        - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 43
                                               AND OT.[Element] = EDP.[Column 1 Element]
                                          THEN OT.[Output Value]
                                          ELSE 0
                                     END, 0)) )
            END AS [Balance - Compulsory] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 16
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 35
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Taken - Compulsory] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 17
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Encashed - Compulsory] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 18
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            + SUM(ISNULL(CASE WHEN EDP.[Sequence] = 36
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Closing Balance - Compulsory] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 19
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Opening Balance - Sick] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 20
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Earned this month - Sick] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 21
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Adjustment - Sick] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 22
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Taken - Sick] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 23
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Closing Balance - Sick] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 24
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Opening Balance - Mine Acc] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 25
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Earned this month - Mine Acc] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 26
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Adjustment - Mine Acc] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 27
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Taken - Mine Acc] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 28
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Closing Balance - Mine Acc] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 31
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 30
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 39
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Opening Balance - HLA] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 41
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Earned this month - HLA] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 31
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Closing Balance - HLA] ,
            CONVERT(DECIMAL(18, 3), 0) AS [AVG Value/Day C/F - Occ value] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 30
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 41
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Adjustment - HLA] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 31
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0))
            - SUM(ISNULL(CASE WHEN EDP.[Sequence] = 39
                                   AND OT.[Element] = EDP.[Column 1 Element]
                              THEN OT.[Output Value]
                              ELSE 0
                         END, 0)) AS [Balance - HLA] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 39
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Encashed - HLA] ,
--NH to get the compulsory leave date in the format MMM YYYY
-- 	left(cast(convert(datetime,(substring(convert(varchar(100),SUM(ISNULL(CASE WHEN EDP.[Sequence] = 50 AND OT.[Element] = EDP.[Column 1 Element] THEN OT.[Output Value] ELSE 190101 END, 190101))),0,7) + '01'),106) as nvarchar(20)),3)
-- 	+ ' ' 
-- 	+ cast(datepart(yyyy,convert(datetime,(substring(convert(varchar(100),SUM(ISNULL(CASE WHEN EDP.[Sequence] = 50 AND OT.[Element] = EDP.[Column 1 Element] THEN OT.[Output Value] ELSE 190101 END, 190101))),0,7) + '01'),106)) as nvarchar(10))
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 50
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE NULL
                       END, NULL)) AS [Compulsory Leave Due Date] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 52
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE NULL
                       END, NULL)) AS [Compulsory Leave Due Date-Start]
    INTO    #GRP
    FROM    #OT OT
            INNER JOIN [Element Document Parameters] EDP WITH ( NOLOCK ) ON EDP.[Document] = 'Payslip GRP Leave'
                                                              AND EDP.[Column 1 Element] = OT.[Element]
            INNER JOIN #Header_Footer HF ON HF.[Resource Tag] = OT.[Resource Tag]
                                            AND HF.[Period Id] = OT.[Period ID]
                                            AND HF.[Payment ID] LIKE '%GRP%'
    GROUP BY OT.[Resource Tag] ,
            OT.[Period ID] ,
            HF.[Payment ID];

-- select '#GRP'
-- select * from #GRP

    UPDATE  #GRP
    SET     [AVG Value/Day B/F - Occ value] = [Opening Balance - Occ value]
            / [Opening Balance - Occ days]
    WHERE   ISNULL([Opening Balance - Occ days], 0) <> 0;
    UPDATE  #GRP
    SET     [AVG Value/Day B/F - Occ value] = 0
    WHERE   ISNULL([Opening Balance - Occ days], 0) = 0;
    UPDATE  #GRP
    SET     [Balance - Occ days] = [Opening Balance - Occ days]
            + [Earned this month - Tot Occ Days] + [Adjustment - Occ days];
    UPDATE  #GRP
    SET     [Balance - Occ value] = [Opening Balance - Occ value]
            + [Earned this month - Occ value] + [Adjustment - Occ value];

    UPDATE  #GRP
    SET     [AVG Value/Day - Occ value] = [Balance - Occ days]
            / [Balance - Occ value]
    WHERE   ISNULL([Balance - Occ value], 0) <> 0;
    UPDATE  #GRP
    SET     [AVG Value/Day - Occ value] = 0
    WHERE   ISNULL([Balance - Occ value], 0) = 0;

    UPDATE  #GRP
    SET     [Taken - Occ value] = [Taken - Occ days]
            * [Opening Balance - Occ value] / [Opening Balance - Occ days]
    WHERE   ISNULL([Opening Balance - Occ days], 0) <> 0;

    IF @Operation = 'GFGS'
        BEGIN
            UPDATE  #GRP
            SET     [Taken - Occ value] = [Balance - Occ value]
                    / [Balance - Occ days]
            WHERE   [Balance - Occ days] <> 0; --ADDED SYM14669
        END;

    UPDATE  #GRP
    SET     [Taken - Occ value] = 0
    WHERE   ISNULL([Opening Balance - Occ days], 0) = 0;


    UPDATE  #GRP
    SET     [AVG Value/Day C/F - Occ value] = [Closing Balance - Occ value]
            / [Closing Balance - Occ days]
    WHERE   ISNULL([Closing Balance - Occ days], 0) <> 0;
    UPDATE  #GRP
    SET     [AVG Value/Day C/F - Occ value] = 0
    WHERE   ISNULL([Balance - Occ value], 0) = 0;
/********--End NH ZA-1124836********/									

--- Gathering BRP Info --
    SELECT DISTINCT
            OT.[Resource Tag] ,
            OT.[Period ID] ,
            EDP.[Item Description] AS [BRP Line Description] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 1
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Ann Car Allow Amt] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 2
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Ann Capital Amt] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 3
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Ann Interest Amt] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 4
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Ann Memo Amt] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 5
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Ann Monthly Earns Amt] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 6
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [HLA Amt] ,
            SUM(ISNULL(CASE WHEN EDP.[Sequence] = 7
                                 AND OT.[Element] = EDP.[Column 1 Element]
                            THEN OT.[Output Value]
                            ELSE 0
                       END, 0)) AS [Ann Monthly Rate Amt]
    INTO    #BRP
    FROM    #OT OT
            INNER JOIN [Element Document Parameters] EDP WITH ( NOLOCK ) ON EDP.[Document] = 'Payslip BRP'
                                                              AND EDP.[Column 1 Element] = OT.[Element]
            INNER JOIN #Header_Footer HF ON HF.[Resource Tag] = OT.[Resource Tag]
                                            AND HF.[Period Id] = OT.[Period ID]
                                            AND HF.[Remuneration Method] = 'BRP'
    GROUP BY OT.[Resource Tag] ,
            OT.[Period ID] ,
            EDP.[Item Description];

/********--Start NH ZA-1124836********/
--NH for GRP Payslip Leave Messages
    INSERT  INTO #Leave_Dates
            SELECT  [Resource Tag] ,			--[Resource Tag]
                    [Period ID] ,			--[Period ID]
                    'GRP' ,					--[Leave Line Description]
                    0 ,						--[Sequence]
                    0 ,						--[New Sequence]
                    [Closing Balance - Compulsory] ,	--[Leave Balance]
                    CONVERT(VARCHAR(50), LEFT(CONVERT(DATETIME, ISNULL(LEFT(CONVERT(VARCHAR(50), [Compulsory Leave Due Date]),
                                                              6), 190101)
                                              + '01'), 3)) + ' '
                    + CONVERT(VARCHAR(50), DATEPART(yyyy,
                                                    CONVERT(DATETIME, ISNULL(LEFT(CONVERT(VARCHAR(50), [Compulsory Leave Due Date]),
                                                              6), 190101)
                                                    + '01')) + 1) ,  --[Leave Due Date MAX]
                    0						--[Number of Days]
            FROM    #GRP;	

    UPDATE  #Leave_Dates
--    SET	[Leave Due Date MAX] = convert(nvarchar(50), convert(datetime, isnull(convert(nvarchar(50),G.[Compulsory Leave Due Date-Start]),19010131)),106)
    SET     [Leave Due Date MAX] = CONVERT(VARCHAR(50), DATEPART(DD,
                                                              CONVERT(DATETIME, ISNULL(LEFT(CONVERT(VARCHAR(50), G.[Compulsory Leave Due Date-Start]),
                                                              8), 19010131))))
            + ' '
            + CONVERT(VARCHAR(50), LEFT(CONVERT(DATETIME, ISNULL(LEFT(CONVERT(VARCHAR(50), G.[Compulsory Leave Due Date-Start]),
                                                              8), 19010131)),
                                        3)) + ' '
            + CONVERT(VARCHAR(50), DATEPART(YYYY,
                                            CONVERT(DATETIME, ISNULL(LEFT(CONVERT(VARCHAR(50), G.[Compulsory Leave Due Date-Start]),
                                                              8), 19010131))))
    FROM    #GRP G ,
            #Header_Footer HF ,
            #Leave_Dates LD
    WHERE   [Leave Balance] > 36.75
            AND G.[Resource Tag] = HF.[Resource Tag]
            AND G.[Period ID] = HF.[Period Id]
            AND LD.[Resource Tag] = HF.[Resource Tag]
            AND LD.[Period ID] = HF.[Period Id]
            AND HF.[Payment ID] IN ( 'GRP-Official', 'GRP-Miner Artisan',
                                     'PLT-GRP-Official' );
 
-- select ' #Leave_Dates'
-- select * from  #Leave_Dates

--Heat 6739

--DROP TABLE #Tmp_MCF

    SELECT  [Resource Tag] ,
            MAX(ISNULL([Expiry Date], [Next Examination Date])) AS [Expiry Date] -- changed GFL00250
    INTO    #Tmp_MCF
    FROM    [Emp Attributes]
    WHERE   [Attribute Category] = 'Medical Certificate of Fitness'
    GROUP BY [Resource Tag];

/********--End NH ZA-1124836********/


--ADDED GFL02436 

    UPDATE  #Header_Footer
    SET     [Message] = ( SELECT    [Message]
                          FROM      [Grp Payslip Message]
                          WHERE     [Remuneration Method] = 'ESOP'
                        )
    WHERE   [Resource Tag] IN (
            SELECT  [Resource Tag]
            FROM    [Resource]
            WHERE   [Resource Reference] IN (
                    SELECT  [Industry Number]
                    FROM    [ESOPS].[Esops Share Allocations] ) )
            AND [Period Id] IN (
            SELECT  [Period ID]
            FROM    [Calendar Periods]
            WHERE   [Start Date] >= '02-Mar-2011'
                    AND [End Date] <= '30-Apr-2011'
                    AND [RunType] = 'normal'
                    AND [Period ID Subtypes] = 'Tax Month 02' );

-- Gather addition Info --
    SELECT DISTINCT
            HF.[Employee number] ,
            HF.[Resource Tag] ,
            HF.[Period Id] ,
            HF.[Pay Cycle] ,
            HF.[Payslip Type] ,
            HF.[Resource Reference] ,
            HF.[Operation] ,
            HF.[Designation] ,
            CD.[Trading Name] ,
            CD.[Postal Address Line 1] ,
            CD.[Postal Address Line 2] ,
            CD.[Postal Address Postal Code] ,
            HF.[Grade] ,
            HF.[Remuneration Method] ,
            HF.[Surname] ,
            HF.[Initials] ,
            HF.[Title] ,
            HF.[Payslip Language] , -- ADDED HEAT 3215 RS
            HF.[Group Engagement Date] ,
            HF.[Mine Engagement Date] ,
--	HF.[Income Security],		--Removed for request 1495601 PVCS vs 2.2
            HF.[Rate Adj Reason] ,		--Request 1495601 PVCS vs 2.2 Add
            HF.[Clocker] ,
            HF.[Novice] ,			--Request 1495601 PVCS vs 2.2 Add
            HF.[Termination Date] ,
            HF.[Bank] ,
            HF.[Bank Branch Name] ,
            HF.[Account Type] ,
            HF.[Account Number] ,
            HF.[Pay Point] ,
            HF.[ID/Passport Number] ,
            CD.[CC/Trust/Co Reg. No] ,
            HF.[Medical Dependants] ,
            HF.[Tax Reference Number] ,
            HF.[Copy] ,
            HF.[Counter] ,
	--HF.[Message],
            CASE WHEN HF.[Operation] IN ( 'Kroondal', 'Blue Ridge' )
                 THEN REPLACE(HF.[Message], 'Sibanye Gold ',
                              'Sibanye Platinum ')
                 ELSE HF.[Message]
            END AS [Message] ,
            HF.[Payslip Number] ,
            HF.[Tax Year] ,
            HF.[Payment ID] ,					--NH ZA-1124836
-- ZA-02136282 Start of removal
--	CASE WHEN HF.[Payslip Type] = 'Interim'
--		THEN RPCal.[End Date]
--		ELSE RPCal.[Start Date]
--	END						AS	[Period Start Date],
--	RPCal.[End Date]				AS	[Period End Date],
--	RPCal.[Previous Date]				AS	[Prev Calendar Date],
--	RPCal.[Previous Shift]				AS	[Prev Calendar Shift],
--	RPCal.[Previous Duration]			AS	[Prev Calendar Duration],
--	RPCal.[Previous NT Minutes]			AS	[Prev Calendar NT Min],
--	RPCal.[Previous Overtime]			AS	[Prev Calendar Overtime],
--	RPCal.[Previous OT Minutes]			AS	[Prev Calendar OT Minutes],
--	RPCal.[Previous Rotation ID]			AS	[Prev Calendar Rotation ID],
--	RPCal.[Previous Shift Allowance]		AS	[Prev Calendar Shift Allowance],
--	RPCal.[Previous Calendar Description]		AS	[Prev Calendar Description],
--	RPCal.[Date]					AS	[Calendar Date],
--	RPCal.[Shift]					AS	[Calendar Shift],
--	RPCal.[Duration]				AS	[Calendar Duration],
--	RPCal.[NT Minutes]				AS	[Calendar NT Min],
--	RPCal.[Overtime]				AS	[Calendar Overtime],
--	RPCal.[OT Minutes]				AS	[Calendar OT Minutes],
--	RPCal.[Rotation ID]				AS	[Calendar Rotation ID],
--	RPCal.[Shift Allowance]				AS	[Calendar Shift Allowance],
--	RPCal.[Calendar Description]			AS	[Calendar Description],
-- ZA-02136282 End of removal
            RPPT.[Item Group] ,
            RPPT.[Sorting] ,
            RPPT.[Line Description] ,
            RPPT.[Reference Number] ,
            RPPT.[Amount] ,
            RPPT.[Units / BBF] ,
            RPPT.[Rate / Adj] ,
            RPPT.[Balance CF] ,
            RPPT.[Input Value] ,
            RPPT.[Comment] ,
            RPPT.[Page Number] ,
            RPPT.[Total Page Number] ,
            RPR.[Service Increment 1] ,
            RPR.[Hourly Rate 1] ,
            RPR.[Basic Rate 1] ,
            RPR.[Make Up 1] ,
            RPR.[Date 1] ,
            RPR.[Remuneration Method 1] ,
            RPR.[Service Increment 2] ,
            RPR.[Hourly Rate 2] ,
            RPR.[Basic Rate 2] ,
            RPR.[Make Up 2] ,
            RPR.[Date 2] ,
            RPR.[Remuneration Method 2] ,
            RPR.[Service Increment 3] ,
            RPR.[Hourly Rate 3] ,
            RPR.[Basic Rate 3] ,
            RPR.[Make Up 3] ,
            RPR.[Date 3] ,
            RPR.[Remuneration Method 3] ,
            BRP.[BRP Line Description] ,
            BRP.[Ann Car Allow Amt] ,
            BRP.[Ann Capital Amt] ,
            BRP.[Ann Interest Amt] ,
            BRP.[Ann Memo Amt] ,
            BRP.[Ann Monthly Earns Amt] ,
            BRP.[HLA Amt] ,
            BRP.[Ann Monthly Rate Amt] ,
            Leave.[Leave Description 1] ,
            Leave.[Leave Balance 1] ,
            Leave.[Leave Description 2] ,
            Leave.[Leave Balance 2] ,
            Leave.[Leave Description 3] ,
            Leave.[Leave Balance 3] ,
            Leave.[Leave Description 4] ,
            Leave.[Leave Balance 4] ,
            Leave.[Leave Description 5] ,
            Leave.[Leave Balance 5] ,
            Leave.[Leave Description 6] ,
            Leave.[Leave Balance 6] ,
            Leave.[Leave Description 7] ,
            Leave.[Leave Balance 7] ,
            Leave.[Leave Description 8] ,
            Leave.[Leave Balance 8] ,
            Leave.[Leave Description 9] ,
            Leave.[Leave Balance 9] ,
            Leave.[Leave Description 10] ,
            Leave.[Leave Balance 10] ,
            Leave.[Leave Description 11] ,
            Leave.[Leave Balance 11] ,
            BR.[BR Description 1] ,
            BR.[BR Balance 1] ,
            BR.[BR Description 2] ,
            BR.[BR Balance 2] ,
            BR.[BR Description 3] ,
            BR.[BR Balance 3] ,
            BR.[BR Description 4] ,
            BR.[BR Balance 4] ,
            BR.[BR Description 5] ,
            BR.[BR Balance 5] ,
            BR.[BR Description 6] ,
            BR.[BR Balance 6] ,
            BR.[BR Description 7] ,
            BR.[BR Balance 7] ,
            BR.[BR Description 8] ,
            BR.[BR Balance 8] ,
            BR.[BR Description 9] ,
            BR.[BR Balance 9] ,
            YTD.[YTD Description 1] ,
            YTD.[YTD Balance 1] ,
            YTD.[YTD Description 2] ,
            YTD.[YTD Balance 2] ,
            YTD.[YTD Description 3] ,
            YTD.[YTD Balance 3] ,
            YTD.[YTD Description 4] ,
            YTD.[YTD Balance 4] ,
            YTD.[YTD Description 5] ,
            YTD.[YTD Balance 5] ,
            YTD.[YTD Description 6] ,
            YTD.[YTD Balance 6] ,
            YTD.[YTD Description 7] ,
            YTD.[YTD Balance 7] ,
            YTD.[YTD Description 8] ,
            YTD.[YTD Balance 8] ,
            YTD.[YTD Description 9] ,
            YTD.[YTD Balance 9] ,
            YTD.[YTD Description 10] ,
            YTD.[YTD Balance 10] ,
            YTD.[YTD Description 11] ,
            YTD.[YTD Balance 11] ,
            YTD.[YTD Description 12] ,
            YTD.[YTD Balance 12] ,
            YTD.[YTD Description 13] ,
            YTD.[YTD Balance 13] ,
            YTD.[YTD Description 14] ,
            YTD.[YTD Balance 14] ,
            YTD.[YTD Description 15] ,
            YTD.[YTD Balance 15] ,
            YTD.[YTD Description 16] ,
            YTD.[YTD Balance 16] ,
            YTD.[YTD Description 17] ,
            YTD.[YTD Balance 17] ,
            YTD.[YTD Description 18] ,
            YTD.[YTD Balance 18] ,
            YTD.[YTD Description 19] ,
            YTD.[YTD Balance 19] ,
            YTD.[YTD Description 20] ,
            YTD.[YTD Balance 20] ,
-- Issue 1396189 PVCS vs 2.1 Start of Change
            YTD.[YTD Description 21] ,
            YTD.[YTD Balance 21] ,
            YTD.[YTD Description 22] ,
            YTD.[YTD Balance 22] ,
            YTD.[YTD Description 23] ,
            YTD.[YTD Balance 23] ,
            YTD.[YTD Description 24] ,
            YTD.[YTD Balance 24] ,
            YTD.[YTD Description 25] ,
            YTD.[YTD Balance 25] ,
-- Issue 1396189 PVCS vs 2.1 End of Change
--Start NH ZA-1124836
            REM1.[Start Date] ,
            REM1.[End Date] ,
            REM1.[Payment ID] AS [1 Payment ID] ,
            REM1.[Gross Remuneration Package (Annual)] ,
            REM1.[Gross Remuneration Package (Monthly)] ,
            ( REM1.[Indiv Gross Rem Package (Annual)] + ( ( REM1.[Premium amt]
                                                            * 12 ) * 0.65 ) ) AS [Indiv Gross Rem Package (Annual)] ,    ---SYM57009 remove isnull
            ( REM1.[Indiv Gross Rem Package (Monthly)] + ( REM1.[Premium amt]
                                                           * 0.65 ) ) AS [Indiv Gross Rem Package (Monthly)] ,         ---SYM57009 remove isnull
	--REM1.[Indiv Gross Rem Package (Annual)],
	--REM1.[Indiv Gross Rem Package (Monthly)],
            REM1.[Pensionable Gross Remuneration Package (Annual)] ,
            REM1.[Pensionable Gross Remuneration Package (Monthly)] ,
            REM1.[Pensionable Emoluments (Annual)] ,
            REM1.[Pensionable Emoluments (Monthly)] ,
            CONVERT(INT, REM1.[Pension Emolument Percentage]) AS [Pension Emolument Percentage] ,
            REM1.[Retirement Fund] ,
            REM1.[Retirement Option] ,
            REM1.[Retirement (Annual)] ,
            REM1.[Retirement (Monthly)] ,
            REM1.[Medical Fund] ,
            REM1.[Medical Fund Option] ,
            REM1.[Medical Fund Value (Annual)] ,
            REM1.[Medical Fund Value (Monthly)] ,
            ( REM1.[Premium amt] * 12 ) AS [Premium Amt (Annual)] ,   ---SYM57009 remove isnull
            REM1.[Premium amt] AS [Premium Amt (Monthly)] ,       ---SYM57009 remove isnull
            CONVERT(FLOAT, REM1.[Addit Ann Leave Days (Annual)]) AS [Addit Ann Leave Days (Annual)] ,
            REM1.[Addit Ann Leave Days (Monthly)] ,
            REM1.[Addit Ann Leave Value (Annual)] ,
            REM1.[Addit Ann Leave Value (Monthly)] ,
            REM1.[Car Allowance Amount (Annual)] ,
            REM1.[Car Allowance Amount (Monthly)] ,
            REM1.[Benefit Value (Annual)] ,
            REM1.[Benefit Value (Monthly)] ,
	--ISNULL((REM1.[Benefit Value (Annual)] + ((REM1.[Premium Amt] * 12) * 0.65)), 0) AS [Basic Value (Annual)],
	--ISNULL((REM1.[Benefit Value (Monthly)] + (REM1.[Premium Amt] * 0.65)),0)  AS [Basic Value (Monthly)],
            REM1.[Benefit Value (Annual)] AS [Basic Value (Annual)] ,    ---SYM57009 remove isnull
            REM1.[Benefit Value (Monthly)] AS [Basic Value (Monthly)] ,   ---SYM57009 remove isnull
            REM1.[Cash Component (Annual)] ,
            REM1.[Cash Component (Monthly)] ,
            REM1.[ARMS Process Status] ,
            REM1.[HLA Percentage] ,
            REM1.[House Ded (Mth)] ,													--NH ZA-1124836
            REM1.[House Ded (Ann)] ,													--NH ZA-1124836
            REM2.[Start Date] AS [2 Start Date] ,
            REM2.[End Date] AS [2 End Date] ,
            REM2.[Payment ID] AS [2 Payment ID] ,
            REM2.[Gross Remuneration Package (Annual)] AS [2 Gross Rem Package (Annual)] ,
            REM2.[Gross Remuneration Package (Monthly)] AS [2 Gross Rem Package (Monthly)] ,
            ( REM2.[Indiv Gross Rem Package (Annual)] + ( ( REM2.[Premium amt]
                                                            * 12 ) * 0.65 ) ) AS [2 Indiv Gross Rem Package (Annual)] ,  ----SYM57009 remove isnull
            ( REM2.[Indiv Gross Rem Package (Monthly)] + ( REM2.[Premium amt]
                                                           * 0.65 ) ) AS [2 Indiv Gross Rem Package (Monthly)] ,        ---SYM57009 remove isnull
	--REM2.[Indiv Gross Rem Package (Annual)]				AS	[2 Indiv Gross Rem Package (Annual)],
	--REM2.[Indiv Gross Rem Package (Monthly)]			AS	[2 Indiv Gross Rem Package (Monthly)],
            REM2.[Pensionable Gross Remuneration Package (Annual)] AS [2 Pensionable Gross Rem Package (Annual)] ,
            REM2.[Pensionable Gross Remuneration Package (Monthly)] AS [2 Pensionable Gross Rem Package (Monthly)] ,
            REM2.[Pensionable Emoluments (Annual)] AS [2 Pensionable Emoluments (Annual)] ,
            REM2.[Pensionable Emoluments (Monthly)] AS [2 Pensionable Emoluments (Monthly)] ,
            CONVERT(INT, REM2.[Pension Emolument Percentage]) AS [2 [Pension Emolument Percentage] ,
            REM2.[Retirement Fund] AS [2 Retirement Fund] ,
            REM2.[Retirement Option] AS [2 Retirement Option] ,
            REM2.[Retirement (Annual)] AS [2 Retirement (Annual)] ,
            REM2.[Retirement (Monthly)] AS [2 Retirement (Monthly)] ,
            REM2.[Medical Fund] AS [2 Medical Fund] ,
            REM2.[Medical Fund Option] AS [2 Medical Fund Option] ,
            REM2.[Medical Fund Value (Annual)] AS [2 Medical Fund Value (Annual)] ,
            REM2.[Medical Fund Value (Monthly)] AS [2 Medical Fund Value (Monthly)] ,
            ( REM2.[Premium amt] * 12 ) AS [2 Premium Amt (Annual)] ,    ---SYM57009 remove isnull
            REM2.[Premium amt] AS [2 Premium Amt (Monthly)] ,           ---SYM57009 remove isnull
            CONVERT(FLOAT, REM2.[Addit Ann Leave Days (Annual)]) AS [2 Addit Ann Leave Days (Annual)] ,
            REM2.[Addit Ann Leave Days (Monthly)] AS [2 Addit Ann Leave Days (Monthly)] ,
            REM2.[Addit Ann Leave Value (Annual)] AS [2 Addit Ann Leave Value (Annual)] ,
            REM2.[Addit Ann Leave Value (Monthly)] AS [2 Addit Ann Leave Value (Monthly)] ,
            REM2.[Car Allowance Amount (Annual)] AS [2 Car Allowance Amount (Annual)] ,
            REM2.[Car Allowance Amount (Monthly)] AS [2 Car Allowance Amount (Monthly)] ,
            REM2.[Benefit Value (Annual)] AS [2 Benefit Value (Annual)] ,
            REM2.[Benefit Value (Monthly)] AS [2 Benefit Value (Monthly)] ,
	--ISNULL((REM2.[Benefit Value (Annual)] + ((REM2.[Premium Amt] * 12) * 0.65)), 0) AS [2 Basic Value (Annual)],
	--ISNULL((REM2.[Benefit Value (Monthly)] + (REM2.[Premium Amt] * 0.65)), 0)  AS [2 Basic Value (Monthly)],
            REM2.[Benefit Value (Annual)] AS [2 Basic Value (Annual)] ,   ---SYM57009 remove isnull
            REM2.[Benefit Value (Monthly)] AS [2 Basic Value (Monthly)] ,   ---SYM57009 remove isnull
            REM2.[Cash Component (Annual)] AS [2 Cash Component (Annual)] ,
            REM2.[Cash Component (Monthly)] AS [2 Cash Component (Monthly)] ,
            REM2.[ARMS Process Status] AS [2 ARMS Process Status] ,
            REM2.[House Ded (Mth)] AS [2 House Ded (Mth)] ,							--NH ZA-1124836
            REM2.[House Ded (Ann)] AS [2 House Ded (Ann)] ,							--NH ZA-1124836
            
		
            rlp1.[Basic Salary_Fixed] ,
			rlp1.[Basic Salary_Fixed_Ann] ,
            rlp1.[Travel Allow_Fixed] ,
			rlp1.[Travel Allow_Fixed_Ann] ,
            rlp1.[13th Checque_Fixed] ,
			rlp1.[13th Checque_Fixed_Ann] ,
            rlp1.[CC PHI_Fixed] ,
			rlp1.[CC PHI_Fixed_Ann] ,
            rlp1.[App Package_Fixed] ,
			rlp1.[App Package_Fixed_Ann] ,
            rlp1.[Non Pens All_Fixed] ,
			rlp1.[Non Pens All_Fixed_Ann] ,
            rlp1.[Transport All_Fixed] ,
			rlp1.[Transport All_Fixed_Ann] ,
            rlp1.[Cell Phone All_Fixed] ,
			rlp1.[Cell Phone All_Fixed_Ann] ,
            rlp1.[CC Pension_Fixed] ,
			rlp1.[CC Pension_Fixed_Ann] ,
            rlp1.[CC Risk_Fixed] ,
			rlp1.[CC Risk_Fixed_Ann] ,
            rlp1.[Other All_Fixed] ,
			rlp1.[Other All_Fixed_Ann] ,
            rlp1.[Vehicle Sacrify_Fixed] ,
			rlp1.[Vehicle Sacrify_Fixed_Ann] ,
            rlp1.[Gross Package_Fixed],
			rlp1.[Gross Package_Fixed_Ann],
			

			rlp2.[Basic Salary_Fixed] [2 Basic Salary_Fixed],
			rlp2.[Basic Salary_Fixed_Ann] [2 Basic Salary_Fixed_Ann],
            rlp2.[Travel Allow_Fixed] [2 Travel Allow_Fixed],
			rlp2.[Travel Allow_Fixed_Ann] [2 Travel Allow_Fixed_Ann],
            rlp2.[13th Checque_Fixed] [2 13th Checque_Fixed],
			rlp2.[13th Checque_Fixed_Ann] [2 13th Checque_Fixed_Ann],
            rlp2.[CC PHI_Fixed] [2 CC PHI_Fixed],
			rlp2.[CC PHI_Fixed_Ann] [2 CC PHI_Fixed_Ann],
            rlp2.[App Package_Fixed] [2 App Package_Fixed],
			rlp2.[App Package_Fixed_Ann] [2 App Package_Fixed_Ann],
            rlp2.[Non Pens All_Fixed] [2 Non Pens All_Fixed],
			rlp2.[Non Pens All_Fixed_Ann] [2 Non Pens All_Fixed_Ann],
            rlp2.[Transport All_Fixed] [2 Transport All_Fixed],
			rlp2.[Transport All_Fixed_Ann] [2 Transport All_Fixed_Ann],
            rlp2.[Cell Phone All_Fixed] [2 Cell Phone All_Fixed],
			rlp2.[Cell Phone All_Fixed_Ann] [2 Cell Phone All_Fixed_Ann],
            rlp2.[CC Pension_Fixed] [2 CC Pension_Fixed],
			rlp2.[CC Pension_Fixed_Ann] [2 CC Pension_Fixed_Ann],
            rlp2.[CC Risk_Fixed] [2 CC Risk_Fixed],
			rlp2.[CC Risk_Fixed_Ann] [2 CC Risk_Fixed_Ann],
            rlp2.[Other All_Fixed] [2 Other All_Fixed],
			rlp2.[Other All_Fixed_Ann] [2 Other All_Fixed_Ann],
            rlp2.[Vehicle Sacrify_Fixed] [2 Vehicle Sacrify_Fixed],
			rlp2.[Vehicle Sacrify_Fixed_Ann] [2 Vehicle Sacrify_Fixed_Ann],
            rlp2.[Gross Package_Fixed] [2 Gross Package_Fixed],
			rlp2.[Gross Package_Fixed_Ann] [2 Gross Package_Fixed_Ann],


			GRP.[Opening Balance - Occ days] ,
            GRP.[Earned this month - Occ days] ,
            GRP.[Adjustment - Occ days] ,
            GRP.[Balance - Occ days] ,
            GRP.[Taken - Occ days] ,
            GRP.[Encashed - Occ days] ,
            GRP.[Closing Balance - Occ days] ,
            GRP.[Earned this month - Extra Occ days] ,
            GRP.[Earned this month - Tot Occ Days] ,
            GRP.[Opening Balance - Occ value] ,
            GRP.[AVG Value/Day B/F - Occ value] ,
            GRP.[Earned this month - Occ value] ,
            GRP.[Adjustment - Occ value] ,
            GRP.[Balance - Occ value] ,
            GRP.[AVG Value/Day - Occ value] ,
            GRP.[Taken - Occ value] ,
            GRP.[Encashed - Occ value] ,
            GRP.[Closing Balance - Occ value] ,
            GRP.[Opening Balance - Compulsory] ,
            GRP.[Earned this month - Compulsory] ,
            GRP.[Adjustment - Compulsory] ,
            GRP.[Balance - Compulsory] ,
            GRP.[Taken - Compulsory] ,
            GRP.[Encashed - Compulsory] ,
            GRP.[Closing Balance - Compulsory] ,
            GRP.[Opening Balance - Sick] ,
            GRP.[Earned this month - Sick] ,
            GRP.[Adjustment - Sick] ,
            GRP.[Taken - Sick] ,
            GRP.[Closing Balance - Sick] ,
            GRP.[Opening Balance - Mine Acc] ,
            GRP.[Earned this month - Mine Acc] ,
            GRP.[Adjustment - Mine Acc] ,
            GRP.[Taken - Mine Acc] ,
            GRP.[Closing Balance - Mine Acc] ,
            GRP.[AVG Value/Day C/F - Occ value] ,
            GRP.[Opening Balance - HLA] ,
            GRP.[Earned this month - HLA] ,
            GRP.[Closing Balance - HLA] ,
            GRP.[Adjustment - HLA] ,
            GRP.[Balance - HLA] ,
            GRP.[Encashed - HLA] ,
            LD.[Leave Balance] ,
            CASE WHEN HF.[Payment ID] LIKE '%GRP%'
                 THEN ISNULL(REPLACE(REPLACE(REPLACE(RPLM.[Message 1],
                                                     '[month/year]',
                                                     RIGHT(LD2.[Leave Due Date MAX],
                                                           8)), '[DD]',
                                             GLS.[Minimum Leave to be Taken]),
                                     '[day/month/year]',
                                     LD2.[Leave Due Date MAX]), '')
                 ELSE ISNULL(REPLACE(REPLACE(REPLACE(RPLM.[Message 1],
                                                     '[month/year]',
                                                     RIGHT(LD2.[Leave Due Date MAX],
                                                           8)), '[DD]',
                                             GLS.[Minimum Leave to be Taken]),
                                     '[day/month/year]',
                                     CONVERT(VARCHAR(11), DATEADD(DD,
                                                              ( -1
                                                              * GLS.[Minimum Leave to be Taken] ),
                                                              LD2.[Leave Due Date MAX]), 106)),
                             '')
            END AS 'Message 1' ,
            CASE WHEN HF.[Payment ID] LIKE '%GRP%'
                 THEN ISNULL(REPLACE(REPLACE(REPLACE(RPLM.[Message 2],
                                                     '[month/year]',
                                                     RIGHT(LD2.[Leave Due Date MAX],
                                                           8)), '[DD]',
                                             GLS.[Minimum Leave to be Taken]),
                                     '[day/month/year]',
                                     LD2.[Leave Due Date MAX]), '')
                 ELSE ISNULL(REPLACE(REPLACE(REPLACE(RPLM.[Message 2],
                                                     '[month/year]',
                                                     RIGHT(LD2.[Leave Due Date MAX],
                                                           8)), '[DD]',
                                             GLS.[Minimum Leave to be Taken]),
                                     '[day/month/year]',
                                     CONVERT(VARCHAR(11), DATEADD(DD,
                                                              ( -1
                                                              * GLS.[Minimum Leave to be Taken] ),
                                                              LD2.[Leave Due Date MAX]), 106)),
                             '')
            END AS 'Message 2' ,
--heat 6739
--heat 6739
            MCF.[Expiry Date] ,
            ISNULL(HF.[MED STATUS], '') AS [MED STATUS] ,   ----SYM40913
            ISNULL(HF.[leave due date start], '') AS [leave due date start] ,  ----SYM40913
            ISNULL(REPLACE(CONVERT(VARCHAR(50), HF.[Employee Tax Start Date], 106),
                           ' ', '-'), '') AS [Employee Tax Start Date],	---SYM40913
            CD.[CO Tel]
    INTO    #Distinct															-- ZA-02136282 Added

    FROM    #Header_Footer HF
            INNER JOIN #Co_Detail CD ON CD.[Operation] = HF.[Operation]
                                        AND CD.[Tax Year] = HF.[Tax Year]
            INNER JOIN [Rpt Payslip Precalc Tbl] RPPT WITH ( NOLOCK ) ON RPPT.[Resource Tag] = HF.[Resource Tag]
                                                              AND RPPT.[Period ID] = HF.[Period Id]
                                                              AND RPPT.[Payslip Type] = 'Payslip'
                                                              AND ( ( RPPT.[Amount] != 0
                                                              OR RPPT.[Balance CF] != 0
                                                              OR RPPT.[Units / BBF] != 0
                                                              OR RPPT.[Item Group] IN (
                                                              'Deductions',
                                                              'Earnings',
                                                              'Net Pay' )
                                                              )
                                                              OR RPPT.[Line Description] LIKE 'Basic%'
                                                              AND ( RPPT.[Amount] = 0
                                                              AND RPPT.[Balance CF] = 0
                                                              )
                                                              )
-- ZA-02136282 Start of Removal
--LEFT OUTER JOIN	[Rpt Payslip Calendars]		RPCal	WITH (NOLOCK)
--							ON	RPCal.[Resource Tag]	=	HF.[Resource Tag]
--							AND	RPCal.[Period ID]	=	HF.[Period ID]
--							AND	RPCal.[Payslip Type]	=	'Payslip'
-- ZA-02136282 End of Removal
            LEFT OUTER JOIN [Rpt Payslip Rates] RPR WITH ( NOLOCK ) ON RPR.[Resource Tag] = HF.[Resource Tag]
                                                              AND RPR.[Period ID] = HF.[Period Id]
            LEFT OUTER JOIN #BRP BRP WITH ( NOLOCK ) ON BRP.[Resource Tag] = HF.[Resource Tag]
                                                        AND BRP.[Period ID] = HF.[Period Id]
            LEFT OUTER JOIN #Tmp_MCF MCF WITH ( NOLOCK ) ON MCF.[Resource Tag] = HF.[Resource Tag]
            LEFT OUTER JOIN #Leave Leave WITH ( NOLOCK ) ON Leave.[Resource Tag] = HF.[Resource Tag]
                                                            AND Leave.[Period ID] = HF.[Period Id]
            LEFT OUTER JOIN #BR BR WITH ( NOLOCK ) ON BR.[Resource Tag] = HF.[Resource Tag]
                                                      AND BR.[Period ID] = HF.[Period Id]
            LEFT OUTER JOIN #YTD YTD WITH ( NOLOCK ) ON YTD.[Resource Tag] = HF.[Resource Tag]
                                                        AND YTD.[Period ID] = HF.[Period Id]
--Start NH ZA-1124836
            LEFT OUTER JOIN #REM_Latest REM1 WITH ( NOLOCK ) ON REM1.[Resource Tag] = HF.[Resource Tag]
                                                              AND REM1.[Period Id] = HF.[Period Id]
            LEFT OUTER JOIN #REM_Previous REM2 WITH ( NOLOCK ) ON REM2.[Resource Tag] = HF.[Resource Tag]
                                                              AND REM2.[Period Id] = HF.[Period Id]
            LEFT OUTER JOIN #REM_LatestPLT AS rlp1 WITH ( NOLOCK ) ON rlp1.[Resource Tag] = HF.[Resource Tag]
                                                              AND rlp1.[Period Id] = HF.[Period Id]
            LEFT OUTER JOIN #REM_PreviousPLT AS rlp2 WITH ( NOLOCK ) ON rlp2.[Resource Tag] = HF.[Resource Tag]
                                                              AND rlp2.[Period Id] = HF.[Period Id]
            LEFT OUTER JOIN #GRP GRP WITH ( NOLOCK ) ON GRP.[Resource Tag] = HF.[Resource Tag]
                                                        AND GRP.[Period ID] = HF.[Period Id]
            LEFT OUTER JOIN [Grp Leave Schemes] GLS WITH ( NOLOCK ) ON HF.[Leave Scheme] = GLS.[Leave Scheme]
            LEFT OUTER JOIN #Leave_Dates LD WITH ( NOLOCK ) ON LD.[Resource Tag] = HF.[Resource Tag]
                                                              AND LD.[Period Id] = HF.[Period Id]
							--AND	(CASE	WHEN HF.[Payment ID] = 'COM'  --SYM58730
                                                              AND ( CASE
                                                              WHEN HF.[Payment ID] LIKE '%COM'
                                                              THEN '4'
                                                              ELSE '0'
                                                              END ) = LD.[Sequence]
--LEFT OUTER JOIN	[Rpt Payslip Leave Message]	RPLM	WITH (NOLOCK)
--							ON	LD.[Leave Balance]	BETWEEN	RPLM.[Start LQS]
--							AND					RPLM.[End LQS]
--							AND	HF.[Remuneration Method] =	RPLM.[Remuneration Method]
--							AND	HF.[Payment ID]		 = 	RPLM.[Payment ID]
            LEFT OUTER JOIN [Rpt Payslip Leave Message] RPLM WITH ( NOLOCK ) ON @DateTo BETWEEN RPLM.[Start Date]
                                                              AND
                                                              RPLM.[End Date]
                                                              AND CASE
                                                              WHEN LD.[Number of Days] >= GLS.[Minimum Leave to be Taken]
                                                              THEN 0
                                                              ELSE LD.[Leave Balance]
                                                              END BETWEEN RPLM.[Start LQS]
                                                              AND
                                                              RPLM.[End LQS]
                                                              AND HF.[Remuneration Method] = RPLM.[Remuneration Method]
                                                              AND HF.[Payment ID] = RPLM.[Payment ID]
                                                              AND HF.[Payslip Type] != 'Interim'
            LEFT OUTER JOIN #Leave_Dates LD2 WITH ( NOLOCK ) ON LD2.[Resource Tag] = HF.[Resource Tag]
                                                              AND LD2.[Period Id] = HF.[Period Id]
							--AND	(CASE	WHEN HF.[Payment ID] = 'COM'   --SYM58730
                                                              AND ( CASE
                                                              WHEN HF.[Payment ID] LIKE '%COM'
                                                              THEN '99'
                                                              ELSE '0'
                                                              END ) = LD2.[Sequence]
--End NH ZA-1124836
    WHERE   ( 0 != CASE WHEN HF.[Payslip Type] != 'Interim'
                        THEN ( SELECT   COUNT(RPPT.[Amount])
                               FROM     [Rpt Payslip Precalc Tbl] RPPT
                               WHERE    ( HF.[Resource Tag] = RPPT.[Resource Tag]
                                          AND HF.[Period Id] = RPPT.[Period ID]
                                          AND RPPT.[Payslip Type] = 'Payslip'
                                        )
                                        AND ( RPPT.[Amount] != 0
                                              OR RPPT.[Balance CF] != 0
                                            )
                             )
                        ELSE ( SELECT   COUNT(RPPT.[Amount])
                               FROM     [Rpt Payslip Precalc Tbl] RPPT
                               WHERE    ( HF.[Resource Tag] = RPPT.[Resource Tag]
                                          AND HF.[Period Id] = RPPT.[Period ID]
                                          AND RPPT.[Payslip Type] = 'Payslip'
                                        )
                                        AND RPPT.[Amount] != 0
                             )
                   END
              OR 0 != ( SELECT  COUNT(RPPT.[Amount])
                        FROM    [Rpt Payslip Precalc Tbl] RPPT
                        WHERE   ( HF.[Resource Tag] = RPPT.[Resource Tag]
                                  AND HF.[Period Id] = RPPT.[Period ID]
                                  AND RPPT.[Payslip Type] = 'Payslip'
                                )
                                AND ( RPPT.[Line Description] LIKE 'Basic%'
                                      OR RPPT.[Line Description] LIKE 'Overtime%'
                                    )
                      )
            )
            AND NOT ( HF.[Payslip Type] = 'Interim'
                      AND HF.[Termination Date] = '31-Dec-9999'
                      AND RPPT.[Item Group] LIKE 'Deductions %'
                      AND RPPT.[Amount] = 0
                    )
            AND NOT ( RPPT.[Item Group] LIKE 'Earnings %'
                      AND RPPT.[Line Description] NOT LIKE 'Basic: %'
                      AND RPPT.[Amount] = 0
                    );






 --   DECLARE @prevPI INT
    
	
	--SET @prevPI = (SELECT TOP 1 [cp].[Period ID] FROM [dbo].[Calendar Periods] AS [cp] INNER JOIN #Distinct AS d ON 1=1
	--WHERE cp.[Period ID] < d.[Period Id]
	--AND cp.[RunType] = 'Normal'
	--AND cp.[Completed] = 'Yes'
	--AND RIGHT(cp.[Period ID],2) = RIGHT(d.[Period Id],2)

	--ORDER BY cp.[Period ID] DESC)	




 --   UPDATE  D
 --   SET     [Units / BBF] = dbo.com_CountString(RPCal.Shift, 'SB')
 --   FROM    #Distinct D
 --           LEFT OUTER JOIN [Rpt Payslip Calendars] RPCal WITH ( NOLOCK ) ON RPCal.[Resource Tag] = D.[Resource Tag]
 --                                                             AND RPCal.[Period ID] = D.[Period Id]
 --                                                             AND RPCal.[Payslip Type] = 'Payslip'
 --   WHERE   [Line Description] = 'Standby Allowance';



 --   UPDATE  D
 --   SET     [Units / BBF] = dbo.com_CountString(RPCal.[Previous Shift], 'SB')
 --   FROM    #Distinct D
 --           LEFT OUTER JOIN [Rpt Payslip Calendars] RPCal WITH ( NOLOCK ) ON RPCal.[Resource Tag] = D.[Resource Tag]
 --                                                             AND RPCal.[Period ID] = D.[Period Id]
 --                                                             AND RPCal.[Payslip Type] = 'Payslip'
 --   WHERE   [Line Description] = 'Standby Allowance (Adj)';

	-----minus prev shifts for adjustments
	 --UPDATE  D
  --  SET     [Units / BBF] =  [Units / BBF] - dbo.com_CountString(RPCal.[Shift], 'SB')
  --  FROM    #Distinct D
  --          LEFT OUTER JOIN [Rpt Payslip Calendars] RPCal WITH ( NOLOCK ) ON RPCal.[Resource Tag] = D.[Resource Tag]
  --                                                            AND RPCal.[Period ID] = @prevPI
  --                                                            AND RPCal.[Payslip Type] = 'Payslip'
  --  WHERE   [Line Description] = 'Standby Allowance (Adj)';

	--SELECT * 
	--INTO #Deductionsline
	--FROM  #Distinct D
	--WHERE [D].[Item Group] LIKE 'Deductions%'
  
--BEGIN SYM11718

    DELETE  #Distinct
    FROM    #Distinct D
            INNER JOIN ( SELECT [Resource Tag] ,
                                [Period Id]
                         FROM   #Distinct
                         WHERE  [Line Description] = 'Suppress Payslip'
                                AND [Amount] = 1
                       ) E ON E.[Resource Tag] = D.[Resource Tag]
                              AND E.[Period Id] = D.[Period Id];

DELETE  dbo.Earnded 
FROM dbo.Earnded AS e INNER JOIN #Distinct AS d ON d.[Resource Tag] = e.[Resource Tag]
AND d.[Period Id] = e.[Period Id] 


INSERT INTO dbo.Earnded
        ( [Resource Tag] ,
          [Period Id] ,
          [Pay Cycle] ,
          [Payslip Type] ,
          [Copy] ,
          [Page Number] ,
          [Payslip Number] ,
          [Item Group 2] ,
          [Sorting - ded] ,
          [Line Description ded] ,
          [reference number ded] ,
          [amount ded] ,
          [Units / BBF ded] ,
          [Balance CF ded]
        )

SELECT [D].[Resource Tag],
[D].[Period Id], 
[D].[Pay Cycle],
[D].[Payslip Type],
[D].[Copy],
d.[Page Number],
[D].[payslip number],
REPLACE([D].[Item Group], 'deductions', 'earnings') AS [Item Group 2], 
--[D].[Item Group] AS [Item Group 2], 
[D].[Sorting] AS [Sorting - ded], 
[D].[Line Description] AS [Line Description ded], 
[D].[reference number] AS [reference number ded],
[D].[amount]  AS [amount ded], 
[D].[Units / BBF] AS [Units / BBF ded], 
[D].[Balance CF] AS [Balance CF ded]
--INTO Earnded
FROM #Distinct D
WHERE [D].[Item Group] LIKE 'Deduction%'
AND  [D].[Amount] <> 0.00

--SELECT * FROM #Earnded

                          
--END SYM11718                          

UPDATE  [Rpt Payslip Calendars] SET [Calendar Description] = REPLACE([RPCal].[Calendar Description],'LCP=Compulsory Leave','SLPT=Statutory Leave'),
[Shift] = REPLACE(RPCal.[Shift],'CP ','ST '),
 [Previous Calendar Description] = REPLACE([RPCal].[Previous Calendar Description],'LCP=Compulsory Leave','SLPT=Statutory Leave'),
[Previous Shift] = REPLACE(RPCal.[Previous Shift],'CP ','ST ')




 FROM    #Distinct D 
			
            LEFT OUTER JOIN [Rpt Payslip Calendars] RPCal WITH ( NOLOCK ) ON RPCal.[Resource Tag] = D.[Resource Tag]
                                                              AND RPCal.[Period ID] = D.[Period Id]
                                                              AND RPCal.[Payslip Type] = 'Payslip'
															  AND D.[Operation] IN ('Kroondal','Blue Ridge')	



UPDATE  [Rpt Payslip Calendars] SET [Calendar Description] = REPLACE([RPCal].[Calendar Description],'LOC=Occasional Leave','NSPT=Non Statutory Leave'),
[Shift] = REPLACE(RPCal.[Shift],'OC ','NS '),
[Previous Calendar Description] = REPLACE([RPCal].[Previous Calendar Description],'LOC=Occasional Leave','NSPT=Non Statutory Leave'),
[Previous Shift] = REPLACE(RPCal.[Previous Shift],'OC ','NS ')

 FROM    #Distinct D 
			
            LEFT OUTER JOIN [Rpt Payslip Calendars] RPCal WITH ( NOLOCK ) ON RPCal.[Resource Tag] = D.[Resource Tag]
                                                              AND RPCal.[Period ID] = D.[Period Id]
                                                              AND RPCal.[Payslip Type] = 'Payslip'
															  AND D.[Operation] IN ('Kroondal','Blue Ridge')	


---- ZA-02136282 Start of Addition
    SELECT  D.* , --	 D.[Expiry Date],
            CASE WHEN D.[Payslip Type] = 'Interim' THEN RPCal.[End Date]
                 ELSE RPCal.[Start Date]
            END AS [Period Start Date] ,
            RPCal.[End Date] AS [Period End Date] ,
            CONVERT(TEXT, RPCal.[Previous Date]) AS [Prev Calendar Date] ,
            CONVERT(TEXT, RPCal.[Previous Shift]) AS [Prev Calendar Shift] ,
            CONVERT(TEXT, RPCal.[Previous Duration]) AS [Prev Calendar Duration] ,
            CONVERT(TEXT, RPCal.[Previous NT Minutes]) AS [Prev Calendar NT Min] ,
            CONVERT(TEXT, RPCal.[Previous Overtime]) AS [Prev Calendar Overtime] ,
            CONVERT(TEXT, RPCal.[Previous OT Minutes]) AS [Prev Calendar OT Minutes] ,
            CONVERT(TEXT, RPCal.[Previous Rotation ID]) AS [Prev Calendar Rotation ID] ,
            CONVERT(TEXT, RPCal.[Previous Shift Allowance]) AS [Prev Calendar Shift Allowance] ,
            CONVERT(TEXT, RPCal.[Previous Calendar Description]) AS [Prev Calendar Description] ,
            CONVERT(TEXT, RPCal.[Date]) AS [Calendar Date] ,
            CONVERT(TEXT, RPCal.[Shift]) AS [Calendar Shift] ,
            CONVERT(TEXT, RPCal.[Duration]) AS [Calendar Duration] ,
            CONVERT(TEXT, RPCal.[NT Minutes]) AS [Calendar NT Min] ,
            CONVERT(TEXT, RPCal.[Overtime]) AS [Calendar Overtime] ,
            CONVERT(TEXT, RPCal.[OT Minutes]) AS [Calendar OT Minutes] ,
            CONVERT(TEXT, RPCal.[Rotation ID]) AS [Calendar Rotation ID] ,
            CONVERT(TEXT, RPCal.[Shift Allowance]) AS [Calendar Shift Allowance] ,
            CONVERT(TEXT, RPCal.[Calendar Description]) AS [Calendar Description]
	
--INTO #Final	 -- SYM43246
    FROM    #Distinct D 
			
            LEFT OUTER JOIN [Rpt Payslip Calendars] RPCal WITH ( NOLOCK ) ON RPCal.[Resource Tag] = D.[Resource Tag]
                                                              AND RPCal.[Period ID] = D.[Period Id]
                                                              AND RPCal.[Payslip Type] = 'Payslip'	;
-- ZA-02136282 End of Addition

--SYM43246

--UPDATE #Final SET [Units / BBF] =  [dbo].[SYMfn_Count_SB] ([Calendar Shift],' ')

--WHERE [Line Description] = 'Standby Allowance'


--UPDATE #Final SET [Units / BBF] =  [dbo].[SYMfn_Count_SB] ([Prev Calendar Shift],' ')

--WHERE [Line Description] = 'Standby Allowance (Adj)'


--SELECT * FROM #Final AS f

-- SYM43246

--set Failed Payslips --

    UPDATE  [Scheduler Report Pool]
    SET     [Status] = NULL
    WHERE   [Status] LIKE 'Fail%'
            AND [Report Name] = 'Payslip';

/*------------------------------------------------------------------
	Sub section
-------------------------------------------------------------------*/


GO