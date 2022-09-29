CREATE TABLE [dbo].[labelfile]
(
[labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [int] NULL,
[locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userlabelname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edicode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_item] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__labelfile__inven__14DBF883] DEFAULT ('N'),
[acct_db] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ic_clear_glnum] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acct_server] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[teamleader_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auto_complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exclude_from_creditcheck] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_move] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[param1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[param2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[param1_label] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[param2_label] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring1_label] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring2_label] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring3] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring4] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring5] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_extrastring6] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[global_label] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [lf_global_default] DEFAULT ('Y'),
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__labelfile__INS_T__5851CED9] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_labelfile] ON [dbo].[labelfile]
FOR DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @labeldefinition varchar(20), @abbr varchar(6), @count int

select @labeldefinition = min(isnull(labeldefinition,'ZZZ'))
  from deleted

while @labeldefinition = 'Fleet' OR @labeldefinition = 'TeamLeader'
begin
  select @abbr = min(abbr)
    from deleted
   where labeldefinition = @labeldefinition
  while @abbr is not null
  begin
    --make sure the fleet abbr is not on any tractors
    if @labeldefinition = 'Fleet'
    begin
      select @count = count(*)
        from tractorprofile
       where trc_fleet = @abbr
      if @count > 0
      begin
        RAISERROR('The Fleet %s is currently used on %d tractor(s).  Please remove from these tractors before deleting.', 16, 1, @abbr, @count)
        ROLLBACK
      end
    end
    --make sure the teamleader does not exist on a driver
    else if @labeldefinition = 'TeamLeader'
    begin
      select @count = count(*)
        from manpowerprofile
       where mpp_teamleader = @abbr
      if @count > 0
      begin
        RAISERROR('The TeamLeader %s is currently used on %d driver(s).  Please remove from these drivers before deleting.', 16, 1, @abbr, @count)
        ROLLBACK
      end
    end
    select @abbr = min(abbr)
      from deleted
     where labeldefinition = @labeldefinition
       and abbr > @abbr
  end
  select @labeldefinition = min(isnull(labeldefinition,'ZZZ'))
    from deleted
     where labeldefinition > @labeldefinition
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_labelfile_rowsec] ON [dbo].[labelfile]
FOR DELETE
AS BEGIN

	SET NOCOUNT ON 
						
	DELETE	RowSecColumnValues 
	FROM	RowSecColumnValues rscv
			INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
			deleted d_lbl
	WHERE	rsc.labeldefinition_values = d_lbl.labeldefinition
			AND rscv.rscv_value = d_lbl.abbr
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecRowColumnValues rsrcv
										INNER JOIN RowSecColumnValues rscv on rscv.rscv_id = rsrcv.rscv_id
										INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
										deleted d_lbl
								WHERE	rsc.labeldefinition_values = d_lbl.labeldefinition
										and rscv.rscv_value = d_lbl.abbr
							)
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* PTS22080 MBR 01/30/04 */
CREATE TRIGGER [dbo].[it_labelfile] ON [dbo].[labelfile]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @maptuit_geocode  	char(1),
        @labeldefinition	VARCHAR(20),
	@abbr			VARCHAR(6),
        @name                   VARCHAR(20),
	@teamleader_email	VARCHAR(50),
	@m2qhid			INTEGER,
    @code int
    
--PTS 61188 JJF 20120620 TotalMailSyncGroups
DECLARE @CursorNeeded bit
DECLARE @TotalMailFleetToGroupsSyncGI char(1)
DECLARE	@NewDispatchGroupName varchar(60)
DECLARE	@NewMemberGroupName varchar(60)
DECLARE @OldDispatchGroupName varchar(60)
DECLARE @OldMemberGroupName varchar(60)
DECLARE @TotalMailConnectionPrefix varchar(1000)
DECLARE	@SQLDyn varchar(2500)
--END PTS 61188 JJF 20120620 TotalMailSyncGroups
--PTS71153 JJF 20130809
DECLARE @TotalMailGroupColumn varchar(30)
DECLARE	@NewNonMemberGroupName varchar(60)
DECLARE @OldNonMemberGroupName varchar(60)
--END PTS71153 JJF 20130809

SELECT @maptuit_geocode = Upper(isnull(gi_string1,'N'))
  FROM generalinfo
 WHERE gi_name = 'MaptuitAlert'
IF @maptuit_geocode = 'Y'
BEGIN
   SELECT @labeldefinition = UPPER(labeldefinition),
          @abbr = isnull(abbr,''),
          @name = isnull(name,''),
          @teamleader_email = isnull(teamleader_email,'')
     FROM inserted

   IF UPPER(@labeldefinition) = 'TEAMLEADER'
   BEGIN
      EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'DispatchUser_DispatchUserID', 'HIL', @abbr)
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'DispatchUser_UserType', 'HIL', 'DM')
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)	
		VALUES (@m2qhid, 'DispatchUser_Email', 'HIL', @teamleader_email)
      INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
   END

   if UPPER(@labeldefinition) = 'FLEET'
   BEGIN
      EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'Fleet_FleetID', 'HIL', @abbr)
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'Fleet_FleetName', 'HIL', @name)
      INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
		VALUES (@m2qhid, 'Fleet_FMUserID', 'HIL', 'TMW')
      INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
   END
END 
/* DPETE 40140 try to keep formats in sequence */
SELECT @labeldefinition = labeldefinition,@abbr = abbr,@code = code
     FROM inserted 
If @labeldefinition = 'InvoiceSelection'
 BEGIN
   If (left(@abbr,1) = 'i' and  isnumeric(substring(@abbr,4,len(@abbr) - 3)) = 1) 
     If @code <> convert(int,substring(@abbr,4,len(@abbr) - 3))
       update labelfile set code =  convert(int,substring(abbr,4,len(abbr) - 3))
		where labeldefinition = 'InvoiceSelection'
		and abbr = @abbr

   If (left(@abbr,1) = 'm' and  isnumeric(substring(@abbr,3,len(@abbr) - 2)) = 1)
    BEGIN
     If @code <> 100000 + (convert(int,substring(@abbr,3,len(@abbr) - 2))) * 10
       update labelfile set code =  100000 + (convert(int,substring(abbr,3,len(abbr) - 2))) * 10
       where labeldefinition = 'InvoiceSelection'
	   and abbr = @abbr
    END
   ELse If (left(@abbr,1) = 'm' and  isnumeric (substring(@abbr,3,len(@abbr) - 3)) = 1)
     BEGIN 
      If @code <> 100000 + (convert(int,substring(@abbr,3,len(@abbr) - 3))* 10) + 1 
        update labelfile set code =  100000 + (convert(int,substring(abbr,3,len(abbr) - 3))* 10) + 1 
        where labeldefinition = 'InvoiceSelection'
	    and abbr = @abbr
     END

 END
 
--PTS 61188 JJF 20120620 TotalMailSyncGroups
--PTS71153 JJF 20130809 - add gi_string2
SELECT	@TotalMailFleetToGroupsSyncGI = UPPER(gi_string1),
		@TotalMailGroupColumn = UPPER(gi_string2)
FROM	generalinfo
WHERE	gi_name = 'TotalMailFleetToGroupsSync'

IF @TotalMailFleetToGroupsSyncGI = 'Y' BEGIN
	SELECT @CursorNeeded = 1
	SELECT	@OldDispatchGroupName = ''
	SELECT	@OldMemberGroupName = ''
	SELECT	@OldNonMemberGroupName = ''
	SELECT	@TotalMailConnectionPrefix = dbo.totalmail_connection_fn()
END

--Cursor set up to iterate through inserted table
--Use for any other processing that must be done one row at a time
IF @CursorNeeded = 1 BEGIN

	DECLARE LabelFileCursor CURSOR FAST_FORWARD FOR
		SELECT	lbl.labeldefinition,
				ISNULL(lbl.abbr, '')
		FROM	inserted lbl

	OPEN	LabelFileCursor

	FETCH NEXT FROM LabelFileCursor
	INTO	@labeldefinition,
			@abbr
			
	WHILE	@@FETCH_STATUS = 0 BEGIN
		--Primary select to fetch info for current row in cursor
		SELECT	@NewDispatchGroupName = ISNULL(lbl.label_extrastring1, ''),
				@NewMemberGroupName = ISNULL(lbl.label_extrastring2, ''),
				@NewNonMemberGroupName = ISNULL(lbl.label_extrastring3, '')
		FROM	inserted lbl
		WHERE	lbl.labeldefinition = @labeldefinition
				AND lbl.abbr = @abbr
		
		--PTS71153 JJF 20130809 - add gi_string2
		IF	@TotalMailFleetToGroupsSyncGI = 'Y' 
			AND @labeldefinition = @TotalMailGroupColumn BEGIN
					
			IF LEN(@NewDispatchGroupName) > 0 BEGIN
				SELECT	@SQLDyn = 'EXEC	' + 
						@TotalMailConnectionPrefix + 'dbo.tm_CreateDispatchGroup ' + 
						'''' + @NewDispatchGroupName + ''', ' +
						'''' + ''', ' +
						'0, ' +
						'0'
				EXEC (@SQLDyn)

			END

			IF LEN(@NewMemberGroupName) > 0 BEGIN
				SELECT	@SQLDyn = 'EXEC ' +
									@TotalMailConnectionPrefix + 'dbo.tm_CreateMemberGroup ' +
									'''' + @NewMemberGroupName + ''', ' +
									'''' + ''', ' + 
									'0, ' +
									'1 '
				EXEC (@SQLDyn)
			END

			IF LEN(@NewNonMemberGroupName) > 0 BEGIN
				SELECT	@SQLDyn = 'EXEC ' +
									@TotalMailConnectionPrefix + 'dbo.tm_CreateMemberGroup ' +
									'''' + @NewNonMemberGroupName + ''', ' +
									'''' + ''', ' + 
									'0, ' +
									'2 '
				EXEC (@SQLDyn)
			END
			
		END

		FETCH NEXT FROM LabelFileCursor
		INTO	@labeldefinition,
				@abbr
	END
	
	CLOSE LabelFileCursor
	DEALLOCATE LabelFileCursor
END
--END PTS 61188 JJF 20120620 TotalMailSyncGroups

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_labelfile_rowsec] ON [dbo].[labelfile]
FOR INSERT, UPDATE

AS BEGIN
	SET NOCOUNT ON 

	IF UPDATE(abbr) BEGIN
		DELETE	RowSecColumnValues 
		FROM	RowSecColumnValues rscv
				INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
				deleted d_lbl
		WHERE	rsc.labeldefinition_values = d_lbl.labeldefinition
				AND rscv.rscv_value = d_lbl.abbr
				AND NOT EXISTS	(	SELECT	*
									FROM	RowSecRowColumnValues rsrcv
											INNER JOIN RowSecColumnValues rscv on rscv.rscv_id = rsrcv.rscv_id
											INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
											deleted d_lbl
									WHERE	rsc.labeldefinition_values = d_lbl.labeldefinition
											and rscv.rscv_value = d_lbl.abbr
								)		
								
		INSERT	RowSecColumnValues (
					rsc_id,
					rscv_value,
					rscv_description
				)
		SELECT DISTINCT	rsc.rsc_id,
				i_lbl.abbr,
				i_lbl.name
		FROM	RowSecColumns rsc,
				inserted i_lbl
		WHERE	rsc.labeldefinition_values = i_lbl.labeldefinition
				AND NOT EXISTS	(	SELECT	*
									FROM	RowSecColumnValues rscv
									WHERE	rscv.rsc_id = rsc.rsc_id
											and rscv.rscv_value = i_lbl.abbr
								)
	END
	
	IF UPDATE(labeldefinition) BEGIN
		UPDATE	RowSecColumnValues
		SET		rscv_description = i_lbl.name
		FROM	RowSecColumnValues rscv
				INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
				inserted i_lbl
		WHERE	rsc.labeldefinition_values = i_lbl.labeldefinition
				and rscv.rscv_value = i_lbl.abbr
	END
	
	IF UPDATE(name) BEGIN
		UPDATE	RowSecColumnValues
		SET		rscv_description = i_lbl.name
		FROM	RowSecColumnValues rscv
				INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id,
				inserted i_lbl
		WHERE	rsc.labeldefinition_values = i_lbl.labeldefinition
				and rscv.rscv_value = i_lbl.abbr
	END
	
	IF UPDATE(userlabelname) BEGIN
		UPDATE	RowSecColumns
		SET		rsc_description = ISNULL	(	(	SELECT	CASE MAX(lbl_inner.userlabelname) 
																WHEN '' THEN NULL
																ELSE MAX(lbl_inner.userlabelname) 
															END
													FROM	labelfile lbl_inner 
													WHERE	lbl_inner.labeldefinition = i_lbl.labeldefinition
												),
												i_lbl.labeldefinition
											)
		FROM	inserted i_lbl,
				RowSecColumns rsc
		WHERE	rsc.labeldefinition_description = i_lbl.labeldefinition
	END
	
END
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_labelfile] on [dbo].[labelfile] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @maptuit_geocode	CHAR(1),
	@labeldefinition	VARCHAR(20),
	@name			VARCHAR(20),
        @abbr                   VARCHAR(6),
	@teamleader_email	VARCHAR(50),
	@m2qhid			INTEGER,
	@retired		CHAR(1) --PTS 38909 EMK Added

--PTS 61188 JJF 20120620 TotalMailSyncGroups
DECLARE @CursorNeeded bit
DECLARE @TotalMailFleetToGroupsSyncGI char(1)
DECLARE	@NewDispatchGroupName varchar(60)
DECLARE	@NewMemberGroupName varchar(60)
DECLARE @OldDispatchGroupName varchar(60)
DECLARE @OldMemberGroupName varchar(60)
DECLARE @TotalMailConnectionPrefix varchar(1000)
DECLARE	@SQLDyn varchar(2500)
--END PTS 61188 JJF 20120620 TotalMailSyncGroups
--PTS71153 JJF 20130809
DECLARE @TotalMailGroupColumn varchar(30)
DECLARE	@NewNonMemberGroupName varchar(60)
DECLARE @OldNonMemberGroupName varchar(60)
--END PTS71153 JJF 20130809

--22080 MBR 03/25/04
IF UPDATE(abbr) OR UPDATE(name) OR UPDATE(teamleader_email)
BEGIN
   SELECT @maptuit_geocode = Upper(isnull(gi_string1,'N'))
     FROM generalinfo
    WHERE gi_name = 'MaptuitAlert'
   IF @maptuit_geocode = 'Y'
   BEGIN
      SELECT @labeldefinition = UPPER(labeldefinition),
             @abbr = isnull(abbr,''),
             @name = isnull(name,''),
             @teamleader_email = isnull(teamleader_email,'')
        FROM inserted

      IF UPPER(@labeldefinition) = 'TEAMLEADER'
      BEGIN
         EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'DispatchUser_DispatchUserID', 'HIL', @abbr)
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'DispatchUser_UserType', 'HIL', 'DM')
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'DispatchUser_Email', 'HIL', @teamleader_email)
         INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
      END
   
      IF UPPER(@labeldefinition) = 'FLEET'
      BEGIN
         EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Fleet_FleetID', 'HIL', @abbr)
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Fleet_FleetName', 'HIL', @name)
         INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
			VALUES (@m2qhid, 'Fleet_FMUserID', 'HIL', 'TMW')
         INSERT INTO m2msgqhdr VALUES (@m2qhid, 'EntityChange', GETDATE(), 'R')
      END
   END
END

if update(userlabelname)
	update labelfile_headers
	set
	CarType1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'CarType1'),
	CarType2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'CarType2'),
	CarType3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'CarType3'),
	CarType4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'CarType4'),
	DrvType1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'DrvType1'),
	DrvType2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'DrvType2'),
	DrvType3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'DrvType3'),
	DrvType4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'DrvType4'),
	RevType1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType1'),
	RevType2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType2'),
	RevType3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType3'),
	RevType4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'RevType4'),
	TrcType1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrcType1'),
	TrcType2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrcType2'),
	TrcType3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrcType3'),
	TrcType4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrcType4'),
	TrlType1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType1'),
	TrlType2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType2'),
	TrlType3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType3'),
	TrlType4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'TrlType4'),
	LghType1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'LghType1'),
	LghType2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'LghType2'),
	LghPermitStatus = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'LghPermitStatus'),
	-- add these 4 for PTS 63045 NQIAO 11/08/12
	BranchRoleUser1 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'BranchRoleUser1'),
	BranchRoleUser2 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'BranchRoleUser2'),
	BranchRoleUser3 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'BranchRoleUser3'),
	BranchRoleUser4 = (SELECT MAX(userlabelname) FROM labelfile WHERE labeldefinition = 'BranchRoleUser4')

--PTS 38909 EMK Remove retired paperwork from billdoctypes and chargetype paperwork
if update(retired)
BEGIN	
	SELECT 	@abbr = isnull(abbr,''),
			@labeldefinition = labeldefinition,
			@retired = retired
	FROM inserted
	IF @retired = 'Y' and @labeldefinition = 'PaperWork'
	BEGIN
		DELETE FROM billdoctypes WHERE bdt_doctype = @abbr
		DELETE FROM chargetypepaperwork WHERE cpw_paperwork = @abbr
	END
END
--PTS 38909

--PTS 61188 JJF 20120620 TotalMailSyncGroups
--PTS71153 JJF 20130809 - add gi_string2
SELECT	@TotalMailFleetToGroupsSyncGI = UPPER(gi_string1),
		@TotalMailGroupColumn = UPPER(gi_string2)
FROM	generalinfo
WHERE	gi_name = 'TotalMailFleetToGroupsSync'

IF @TotalMailFleetToGroupsSyncGI = 'Y' BEGIN
	SELECT @CursorNeeded = 1
	SELECT	@TotalMailConnectionPrefix = dbo.totalmail_connection_fn()
END

--Cursor set up to iterate through inserted table
--Use for any other processing that must be done one row at a time
IF @CursorNeeded = 1 BEGIN
	DECLARE LabelFileCursor CURSOR FAST_FORWARD FOR
		SELECT	lbl.labeldefinition,
				ISNULL(lbl.abbr, '')
		FROM	inserted lbl

	OPEN	LabelFileCursor

	FETCH NEXT FROM LabelFileCursor
	INTO	@labeldefinition,
			@abbr
			
	WHILE	@@FETCH_STATUS = 0 BEGIN
		--Primary select to fetch info for current row in cursor
		SELECT	@NewDispatchGroupName = ISNULL(lbl.label_extrastring1, ''),
				@NewMemberGroupName = ISNULL(lbl.label_extrastring2, ''),
				@NewNonMemberGroupName = ISNULL(lbl.label_extrastring3, '')
		FROM	inserted lbl
		WHERE	lbl.labeldefinition = @labeldefinition
				AND lbl.abbr = @abbr

		--Primary select to fetch info for current row in cursor
		SELECT	@OldDispatchGroupName = ISNULL(lbl.label_extrastring1, ''),
				@OldMemberGroupName = ISNULL(lbl.label_extrastring2, ''),
				@OldNonMemberGroupName = ISNULL(lbl.label_extrastring3, '')
		FROM	deleted lbl
		WHERE	lbl.labeldefinition = @labeldefinition
				AND lbl.abbr = @abbr

		--PTS71153 JJF 20130809 - add gi_string2
		IF	@TotalMailFleetToGroupsSyncGI = 'Y'
			AND @labeldefinition = @TotalMailGroupColumn 
			AND	(	UPDATE(label_extrastring1) 
					OR UPDATE(label_extrastring2)
					OR UPDATE(label_extrastring3)
				) BEGIN
			
			IF UPDATE(label_extrastring1) AND LEN(@NewDispatchGroupName) > 0 BEGIN
				SELECT	@SQLDyn = 'EXEC	' + 
									@TotalMailConnectionPrefix + 'dbo.tm_CreateDispatchGroup ' + 
									'''' + @NewDispatchGroupName + ''', ' +
									'''' + ''', ' +
									'0, ' +
									'0'
				EXEC (@SQLDyn)
			END

			IF UPDATE(label_extrastring2) AND LEN(@NewMemberGroupName) > 0 BEGIN
				SELECT	@SQLDyn = 'EXEC ' +
									@TotalMailConnectionPrefix + 'dbo.tm_CreateMemberGroup ' +
									'''' + @NewMemberGroupName + ''', ' +
									'''' + ''', ' + 
									'0, ' +
									'1 '
				EXEC (@SQLDyn)
			END		
			
			IF UPDATE(label_extrastring3) AND LEN(@NewNonMemberGroupName) > 0 BEGIN
				SELECT	@SQLDyn = 'EXEC ' +
									@TotalMailConnectionPrefix + 'dbo.tm_CreateMemberGroup ' +
									'''' + @NewNonMemberGroupName + ''', ' +
									'''' + ''', ' + 
									'0, ' +
									'2 '
				EXEC (@SQLDyn)
			END		

		END
			
		FETCH NEXT FROM LabelFileCursor
		INTO	@labeldefinition,
				@abbr
	END

	CLOSE LabelFileCursor
	DEALLOCATE LabelFileCursor
END
--END PTS 61188 JJF 20120620 TotalMailSyncGroups

GO
ALTER TABLE [dbo].[labelfile] ADD CONSTRAINT [pkey_label] PRIMARY KEY CLUSTERED ([labeldefinition], [abbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_abbr] ON [dbo].[labelfile] ([abbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [labelfile_INS_TIMESTAMP] ON [dbo].[labelfile] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_label] ON [dbo].[labelfile] ([labeldefinition], [abbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_labelfile_timestamp] ON [dbo].[labelfile] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[labelfile] TO [public]
GO
GRANT INSERT ON  [dbo].[labelfile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[labelfile] TO [public]
GO
GRANT SELECT ON  [dbo].[labelfile] TO [public]
GO
GRANT UPDATE ON  [dbo].[labelfile] TO [public]
GO
