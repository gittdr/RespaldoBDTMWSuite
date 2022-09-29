CREATE TABLE [dbo].[payheader]
(
[pyh_payperiod] [datetime] NULL,
[pyh_paystatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_prorap] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_currencydate] [datetime] NULL,
[pyh_pyhnumber] [int] NULL,
[timestamp] [timestamp] NULL,
[asgn_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_totalcomp] [money] NULL,
[pyh_totaldeduct] [money] NULL,
[pyh_totalreimbrs] [money] NULL,
[crd_cardnumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_checknumber] [int] NULL,
[pyh_issuedate] [datetime] NULL,
[pyh_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_days_athome] [int] NULL,
[payee_invoice_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payee_invoice_date] [datetime] NULL,
[pyh_lgh_number] [int] NULL,
[termCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__payheader__INS_T__688836A2] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dtpayheader] ON [dbo].[payheader] 
FOR  DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added


/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------
	05/17/2001	Vern Jewett		(none)	PTS 10379: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
*/


--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581



declare	@ls_audit	varchar(1)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--vmj1+
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
	--vmj1-
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@tmwuser
			,'PayHeader deleted'
			,getdate()
			,''
			,convert(varchar(20), pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	deleted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itpayheader] ON [dbo].[payheader] 
FOR  INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581
--PTS84591 MBR 01/19/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------
	05/17/2001	Vern Jewett		(none)	PTS 10379: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
	10/12/2005	Jude Dsouza		30132	Replaced convoluted subquery with simple select on gi table.
*/

declare	@ls_audit	varchar(1)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

If exists (select * from generalinfo where gi_name = 'FingerprintAudit' and gi_string1 = 'Y') -- JD 30132 

	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@tmwuser
			,'PayHeader inserted'
			,getdate()
			,''
			,convert(varchar(20), pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	inserted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_payheader] ON [dbo].[payheader]
   FOR INSERT, UPDATE
AS
SET NOCOUNT ON

--PTS84591 MBR 01/19/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

/**
 *
 * NAME
 * iut_payheader
 *
 * TYPE
 * Trigger
 *
 * DESCRIPTION
 * Insert, Update Trigger on PayHeader Table
 *
 * RETURNS
 *
 * PTS#61543 SPN Created Initial Version
 *
 */

BEGIN

   DECLARE @DuplicateCheck VARCHAR(60)
   DECLARE @Error          VARCHAR(500)
   DECLARE @row_type       CHAR(3)
   DECLARE @pyh_pyhnumber  INT
   DECLARE @asgn_type      CHAR(6)
   DECLARE @asgn_id        VARCHAR(13)
   DECLARE @pyh_payperiod  DATETIME
   DECLARE @pyh_lgh_number INT

   DECLARE iut_pyhcur CURSOR FOR
    SELECT (CASE WHEN d.pyh_pyhnumber IS NULL THEN 'NEW' ELSE 'OLD' END) AS row_type
         , i.pyh_pyhnumber
         , i.asgn_type
         , i.asgn_id
         , i.pyh_payperiod
         , i.pyh_lgh_number
      FROM Inserted i
    LEFT OUTER JOIN deleted d ON i.pyh_pyhnumber = d.pyh_pyhnumber

   IF EXISTS (SELECT * FROM triggerbypass WHERE moduleid = app_name())
      RETURN

   SELECT @DuplicateCheck = gi_string1
     FROM generalinfo
    WHERE gi_name = 'STL_PAYHEADER_DUPLICATECHECK'
   IF @DuplicateCheck IS NULL
      SELECT @DuplicateCheck = 'NONE'

   SELECT @Error = ''

   IF @DuplicateCheck = 'NONE'
      --No Duplicate Check
      SELECT @Error = ''
   ELSE
      BEGIN
         OPEN iut_pyhcur
         WHILE 1 = 1
         BEGIN
            FETCH NEXT FROM iut_pyhcur
             INTO @row_type
                , @pyh_pyhnumber
                , @asgn_type
                , @asgn_id
                , @pyh_payperiod
                , @pyh_lgh_number

            IF @@FETCH_STATUS <> 0
               BREAK

            IF @DuplicateCheck = 'ASGN_TYPE_ASGN_ID_PYH_PAYPERIOD'
               IF EXISTS (SELECT 1
                            FROM payheader
                           WHERE asgn_type     = @asgn_type
                             AND asgn_id       = @asgn_id
                             AND pyh_payperiod = @pyh_payperiod
                             AND (CASE WHEN @row_type = 'NEW' THEN 0 ELSE @pyh_pyhnumber END) <> pyh_pyhnumber
                         )
                  SELECT @Error = 'Asset for the Pay Period already exist'
            ELSE IF @DuplicateCheck = 'ASGN_TYPE_ASGN_ID_PYH_PAYPERIOD_PYH_LGH_NUMBER'
               IF EXISTS (SELECT 1
                            FROM payheader
                           WHERE asgn_type      = @asgn_type
                             AND asgn_id        = @asgn_id
                             AND pyh_payperiod  = @pyh_payperiod
                             AND pyh_lgh_number = @pyh_lgh_number
                             AND (CASE WHEN @row_type = 'NEW' THEN 0 ELSE @pyh_pyhnumber END) <> pyh_pyhnumber
                         )
                  SELECT @Error = 'Asset for the Pay Period and Trip# already exist'
         END
         CLOSE iut_pyhcur
         DEALLOCATE iut_pyhcur
      END

      IF @Error <> ''
      BEGIN
         ROLLBACK TRANSACTION
         RAISERROR(@Error, 16, 1) WITH SETERROR
      END

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_payheaderTplActive] ON [dbo].[payheader] FOR INSERT, UPDATE AS
/*******************************************************************************************************************
  Object Description:
  This trigger will inform 3PL queues about changes in pay when pay status changed to REL.
  Revision History:
  Date         Name             Label/PTS     Description
  -----------  ---------------  ------------- ----------------------------------------
  05/16/2016   Suprakash Nandan PTS: 102052   Initial Release
  08/23/2016   Suprakash Nandan PTS: 104278   Added SET NOCOUNT
  04/18/2017   AV               NSUITE-201159 Widen pyh_paystatus to include XFR
********************************************************************************************************************/
SET NOCOUNT ON
BEGIN
   DECLARE @id          INT
   DECLARE @max         INT
   DECLARE @MoveNumber  INT

   DECLARE @PayReleased TABLE
   ( ID           INT IDENTITY NOT NULL
   , MoveNumber   INT          NOT NULL
   )

   --SET NOCOUNT ON
   IF NOT EXISTS (SELECT TOP 1 1 FROM inserted) RETURN

   INSERT INTO @PayReleased
   ( MoveNumber )
   SELECT DISTINCT l.mov_number
     FROM paydetail d
     JOIN inserted h ON d.pyh_number = h.pyh_pyhnumber
     JOIN legheader l ON d.lgh_number = l.lgh_number
    WHERE h.pyh_paystatus IN ('REL', 'XFR')

   SELECT @id = 0
   SELECT @max = MAX(ID) FROM @PayReleased

   WHILE @id < @max
   BEGIN
      SELECT @id = MIN(id)
        FROM @PayReleased
       WHERE id > @id

      SELECT @MoveNumber = MoveNumber
        FROM @PayReleased
       WHERE id = @id

      BEGIN
         EXEC TPLActiveObjectsQueue @MoveNumber, 'PAYHEADER'
      END
   END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[utpayheader] ON [dbo].[payheader]
FOR UPDATE   
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------------------------------------------------------------
	05/17/2001	Vern Jewett		(none)	PTS 10379: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
	07/30/2002 	David Mook		DM_HOT	If update pay status then sync paydetail status		
	02/14/2003  Todd DiGiacinto [15036] PTS 15036: Fixing DM_HOT (couldn't handle multi-row updates).	
	10/12/2005	Jude DSouza		[30132]	Made expedite_audit inserts unconditional updates removed. Moved DM TD code to the top of trigger
											
*/

--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581
--PTS84591 MBR 01/19/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

declare @ls_user         varchar(20)
	,@ldt_updated_dt datetime
        ,@ls_audit       varchar(1)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

-- JD 10/12/05 moved this code here so that it runs even if fingerprintaudit is turned off.
if update(pyh_paystatus)
begin
	--[15036] Commented DM_HOT code, replacement code below.

	--[15036] Replacement code
	Update Paydetail
	Set pyd_status = 'REL'
	From
		Paydetail inner join inserted on paydetail.pyh_number = inserted.pyh_pyhnumber
	where 
		inserted.pyh_pyhnumber > 0
		and 
		pyd_status <> 'REL'
		and
		pyh_paystatus in ('REL', 'XFR')
end				
	--[15036] New code ends
	--================================


-- JD 40574 this is no longer needed
-- JD 10/12/05 moved this code here so that it runs even if fingerprintaudit is turned off.
-- [15036] replacement code
-- if update(pyh_totalcomp) OR  update(pyh_totalDeduct) or update(pyh_totalreimbrs)
-- BEGIN
-- 
-- UPDATE payheader 
--    SET pyh_totalcomp = (SELECT SUM(pyd_amount) 
--                           FROM paydetail 
--                          WHERE pyh_pyhnumber = pyh_number AND 
--                                pyd_pretax = 'Y' AND 
--                                pyd_status <> 'HLD'), 
--        pyh_totaldeduct = (SELECT SUM(pyd_amount) 
--                           FROM paydetail 
--                          WHERE pyh_pyhnumber = pyh_number AND 
--                                pyd_pretax = 'N' AND 
--                                pyd_status <> 'HLD' AND 
--                                pyd_minus = -1), 
--        pyh_totalreimbrs = (SELECT SUM(pyd_amount) 
--                           FROM paydetail 
--                          WHERE pyh_pyhnumber = pyh_number AND 
--                                pyd_pretax = 'N' AND 
--                                pyd_status <> 'HLD' AND 
--                                pyd_minus = 1)
--  WHERE pyh_pyhnumber IN (SELECT pyh_pyhnumber FROM inserted)
-- 
-- -- update the total compensation to 0 when the value is NULL
-- UPDATE payheader 
--    SET pyh_totalcomp = 0 
--  WHERE pyh_totalcomp IS NULL AND 
--        pyh_pyhnumber IN (SELECT pyh_pyhnumber FROM inserted)
-- 
-- -- update the total deductions to 0 when the value is NULL
-- UPDATE payheader 
--    SET pyh_totaldeduct = 0 
--  WHERE pyh_totaldeduct IS NULL AND 
--        pyh_pyhnumber IN (SELECT pyh_pyhnumber FROM inserted)
-- 
-- -- update the total reimbursed to 0 when the value is NULL
-- UPDATE payheader 
--    SET pyh_totalreimbrs = 0 
--  WHERE pyh_totalreimbrs IS NULL AND 
--        pyh_pyhnumber IN (SELECT pyh_pyhnumber FROM inserted)
-- END
-- [15036] End replacement code
-- JD 10/12/05 End of code move.
-- END JD 40574 this is no longer needed 1/25/08

If not exists (select * from generalinfo where gi_name = 'FingerprintAudit' and gi_string1 = 'Y')
Return


select 	@ls_user = @tmwuser
		,@ldt_updated_dt = getdate()


--*****************************************************************************************************************************************
	-- AS part of PTS 30132 All the expedite_audit updates have been removed and Inserts made unconditional
	-- Always insert a row,if you get too much data thats ok, the check on the expedite_audit table forces a recompile on the trigger
	-- Large customers have millions of rows in this table and checking to see if a row exists in the audit table is a costly operation
	-- that holds up the update and results in recompiles and excessive locking.
--*****************************************************************************************************************************************

/*Log to the expedite_audit table.  I'm going to assume that they will
never update the Primary Key, 
	pyh_pyhnumber..	*/
--TotalEarnings..
if update(pyh_totalcomp)
begin


	/* Update the rows that already exist.  Note below that -5100000000000.07 is an unlikely numeric 
		value that is representing NULL in comparisons..
*/
/*
	update	expedite_audit
	  set	update_note = ea.update_note + ', TotalEarnings ' + 
                              isnull(convert(varchar(20), d.pyh_totalcomp), 'null') + ' -> ' + 
	                      isnull(convert(varchar(20), i.pyh_totalcomp), 'null')
	  from	expedite_audit ea
		,deleted d
		,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_totalcomp, -5100000000000.07) <> isnull(d.pyh_totalcomp, -5100000000000.07)
		and	ea.ord_hdrnumber = 0
		and	ea.updated_by = @ls_user
		and	ea.activity = 'PayHeader updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyh_pyhnumber)
		and	ea.mov_number = 0
		and	ea.lgh_number = 0
		and	ea.join_to_table_name = 'payheader'

*/
	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@ls_user
			,'PayHeader updated'
			,@ldt_updated_dt
			,'TotalEarnings ' + isnull(convert(varchar(20), d.pyh_totalcomp), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.pyh_totalcomp), 'null')
			,convert(varchar(20), i.pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_totalcomp, -5100000000000.07) <> isnull(d.pyh_totalcomp, -5100000000000.07)
	/*	and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = 0
				and	ea2.updated_by = @ls_user
				and	ea2.activity = 'PayHeader updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyh_pyhnumber)
				and	ea2.mov_number = 0
				and	ea2.lgh_number = 0
				and	ea2.join_to_table_name = 'payheader')*/
end


--TotalExpenses..
if update(pyh_totaldeduct)
begin
	--Update the rows that already exist..
/*	update	expedite_audit
	  set	update_note = ea.update_note + ', TotalExpenses ' + isnull(convert(varchar(20), d.pyh_totaldeduct), 'null')                               + ' -> ' + isnull(convert(varchar(20), i.pyh_totaldeduct), 'null')
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_totaldeduct, -5100000000000.07) <> isnull(d.pyh_totaldeduct, -5100000000000.07)
		and	ea.ord_hdrnumber = 0
		and	ea.updated_by = @ls_user
		and	ea.activity = 'PayHeader updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyh_pyhnumber)
		and	ea.mov_number = 0
		and	ea.lgh_number = 0
		and	ea.join_to_table_name = 'payheader'*/


	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@ls_user
			,'PayHeader updated'
			,@ldt_updated_dt
			,'TotalExpenses ' + isnull(convert(varchar(20), d.pyh_totaldeduct), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.pyh_totaldeduct), 'null')
			,convert(varchar(20), i.pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_totaldeduct, -5100000000000.07) <> 
				isnull(d.pyh_totaldeduct, -5100000000000.07)
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = 0
				and	ea2.updated_by = @ls_user
				and	ea2.activity = 'PayHeader updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyh_pyhnumber)
				and	ea2.mov_number = 0
				and	ea2.lgh_number = 0
				and	ea2.join_to_table_name = 'payheader')*/
end


--TotalReimbursements..
if update(pyh_totalreimbrs)
begin
	--Update the rows that already exist..
/*	update	expedite_audit
	  set	update_note = ea.update_note + ', TotalReimbursements ' + 
	                      isnull(convert(varchar(20), d.pyh_totalreimbrs), 'null') + ' -> ' + 
	                      isnull(convert(varchar(20), i.pyh_totalreimbrs), 'null')
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_totalreimbrs, -5100000000000.07) <>

				isnull(d.pyh_totalreimbrs, -5100000000000.07)
		and	ea.ord_hdrnumber = 0
		and	ea.updated_by = @ls_user
		and	ea.activity = 'PayHeader updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyh_pyhnumber)
		and	ea.mov_number = 0
		and	ea.lgh_number = 0
		and	ea.join_to_table_name = 'payheader'*/


	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@ls_user
			,'PayHeader updated'
			,@ldt_updated_dt
			,'TotalReimbursements ' + isnull(convert(varchar(20), d.pyh_totalreimbrs), 'null') + 
				' -> ' + isnull(convert(varchar(20), i.pyh_totalreimbrs), 'null')
			,convert(varchar(20), i.pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_totalreimbrs, -5100000000000.07) <> isnull(d.pyh_totalreimbrs, -5100000000000.07)
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = 0
				and	ea2.updated_by = @ls_user
				and	ea2.activity = 'PayHeader updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyh_pyhnumber)
				and	ea2.mov_number = 0
				and	ea2.lgh_number = 0
				and	ea2.join_to_table_name = 'payheader') */
end


--PayPeriod..
if update(pyh_payperiod)
begin
	/* Update the rows that already exist.  Note below that '1901-03-30' is an unlikely date value
		that is representing NULL in comparisons..	*/
/*	update	expedite_audit
	  set	update_note = ea.update_note + ', PayPeriod ' + 
                              isnull(convert(varchar(30), d.pyh_payperiod, 101), 'null') + ' -> ' + 
                              isnull(convert(varchar(30), i.pyh_payperiod, 101), 'null')
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_payperiod, '1901-03-30') <> isnull(d.pyh_payperiod, '1901-03-30')
		and	ea.ord_hdrnumber = 0
		and	ea.updated_by = @ls_user
		and	ea.activity = 'PayHeader updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyh_pyhnumber)
		and	ea.mov_number = 0
		and	ea.lgh_number = 0
		and	ea.join_to_table_name = 'payheader' */


	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@ls_user
			,'PayHeader updated'
			,@ldt_updated_dt
			,'PayPeriod ' + isnull(convert(varchar(30), d.pyh_payperiod, 101), 'null') + ' -> ' + 
				isnull(convert(varchar(30), i.pyh_payperiod, 101), 'null')
			,convert(varchar(20), i.pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_payperiod, '1901-03-30') <> isnull(d.pyh_payperiod, '1901-03-30')
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = 0
				and	ea2.updated_by = @ls_user
				and	ea2.activity = 'PayHeader updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyh_pyhnumber)
				and	ea2.mov_number = 0
				and	ea2.lgh_number = 0
				and	ea2.join_to_table_name = 'payheader')*/
end


/* Status.  Note below that 'nU1L' is an unlikely string value that is
representing NULL in 
	comparisons..	*/
if update(pyh_paystatus)
begin
/*
	--Update the rows that already exist..
	update	expedite_audit
	  set	update_note = ea.update_note + ', Status ' + ltrim(rtrim(isnull(d.pyh_paystatus, 'null'))) + ' -> ' + 
                              ltrim(rtrim(isnull(i.pyh_paystatus, 'null')))
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_paystatus, 'null') <> isnull(d.pyh_paystatus, 'null')
		and	ea.ord_hdrnumber = 0
		and	ea.updated_by = @ls_user
		and	ea.activity = 'PayHeader updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyh_pyhnumber)
		and	ea.mov_number = 0
		and	ea.lgh_number = 0
		and	ea.join_to_table_name = 'payheader'*/


	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select 0
			,@ls_user
			,'PayHeader updated'
			,@ldt_updated_dt
			,'Status ' + ltrim(rtrim(isnull(d.pyh_paystatus, 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull(i.pyh_paystatus, 'null')))
			,convert(varchar(20), i.pyh_pyhnumber)
			,0
			,0
			,'payheader'
	  from	deleted d
			,inserted i
	  where	i.pyh_pyhnumber = d.pyh_pyhnumber
		and	isnull(i.pyh_paystatus, 'null') <> isnull(d.pyh_paystatus, 'null')
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = 0
				and	ea2.updated_by = @ls_user
				and	ea2.activity = 'PayHeader updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyh_pyhnumber)
				and	ea2.mov_number = 0
				and	ea2.lgh_number = 0
				and	ea2.join_to_table_name = 'payheader')*/
end


GO
CREATE NONCLUSTERED INDEX [pyh_pk_typeiddate] ON [dbo].[payheader] ([asgn_type], [asgn_id], [pyh_payperiod], [pyh_lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [payheader_INS_TIMESTAMP] ON [dbo].[payheader] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_pyh_payprd] ON [dbo].[payheader] ([pyh_payperiod], [pyh_payto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_pyh_stat] ON [dbo].[payheader] ([pyh_paystatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_pyh_toperiod] ON [dbo].[payheader] ([pyh_payto], [pyh_payperiod]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_pyh_head] ON [dbo].[payheader] ([pyh_pyhnumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_pyh_refnum_type_lghnum] ON [dbo].[payheader] ([pyh_ref_number], [pyh_ref_type], [pyh_lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_payheader_pyh_ref_number] ON [dbo].[payheader] ([pyh_ref_type], [pyh_ref_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_payheader_timestamp] ON [dbo].[payheader] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payheader] TO [public]
GO
GRANT INSERT ON  [dbo].[payheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payheader] TO [public]
GO
GRANT SELECT ON  [dbo].[payheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[payheader] TO [public]
GO
