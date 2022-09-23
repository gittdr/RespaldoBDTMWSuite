CREATE TABLE [dbo].[notes]
(
[not_number] [int] NOT NULL,
[not_text] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_urgent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_senton] [datetime] NULL,
[not_sentby] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_expires] [datetime] NULL,
[not_forwardedfrom] [int] NULL,
[timestamp] [timestamp] NULL,
[ntb_table] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nre_tablekey] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_sequence] [smallint] NULL,
[last_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedatetime] [datetime] NULL,
[autonote] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_text_large] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_viewlevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntb_table_copied_from] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nre_tablekey_copied_from] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_number_copied_from] [int] NULL,
[not_tmsend] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_copy_to_order] [bit] NULL CONSTRAINT [DF_notes_not_copy_to_order] DEFAULT ((0)),
[not_profile_only] [bit] NULL CONSTRAINT [DF_notes_not_profile_only] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[iudt_notes] ON [dbo].[notes] FOR INSERT,UPDATE,DELETE AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/*	Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------
	08/23/2001	Vern Jewett		vmj1	PTS 11797, CTX Item #53: store fingerprint entry
										when priority or text is changed.
	02/28/2002	Vern Jewett		vmj2	PTS 12286: don't insert audit row unless the feature is turned on.

	02/06/2006	Jim Teubner				add entries into a new notes_audit table to track changes/deletes
    10/15/2007  SLM                     PTS 39478 Based upon GI setting DoNotUseCopyProcAsUser, update 
                                        notes.last_updatedby column with itself
	
	02/26/2009  CJB/KMM			CJB		Performance fixes (44833)-- Remove checks for existing records before performing insert, just insert.

*/

declare	@li_insert_count 			int
		,@li_delete_count		int
		,@ls_user			varchar(20)
		,@ldt_updated_dt		datetime
		,@ls_audit			varchar(1)
        ,@DoNotUseCopyProcAsUser varchar(1)

-- JET - PTS 31658 - 2/6/2006
-- Place an entry in the note audit table (to track insert, updates and deletes
-- capture previous values for deleted notes
insert into notes_audit (audit_datetime,  audit_loguser,  audit_dbuser, 
                         audit_application, audit_type, not_number, not_text, 
                         not_type, not_urgent, not_senton, not_sentby, not_expires, 
                         not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, 
                         last_updatedby, last_updatedatetime, autonote, 
--not_text_large, 
                         not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, 
                         not_number_copied_from, not_tmsend)
     select getdate(),  system_user,  user, 
            app_name(), 'DELETE', not_number, not_text, 
            not_type, not_urgent, not_senton, not_sentby, not_expires, 
            not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, 
            last_updatedby, last_updatedatetime, autonote, 
--not_text_large, 
            not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, 
            not_number_copied_from, not_tmsend 
       from deleted 
      where not_number in (select distinct not_number from deleted) and 
            not_number not in (select distinct not_number from inserted) 
-- capture inserted or new notes (notes only in the inserted table)
insert into notes_audit (audit_datetime,  audit_loguser,  audit_dbuser, 
                         audit_application, audit_type, not_number, not_text, 
                         not_type, not_urgent, not_senton, not_sentby, not_expires, 
                         not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, 
                         last_updatedby, last_updatedatetime, autonote, not_text_large, 
                         not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, 
                         not_number_copied_from, not_tmsend)
     select getdate(),  system_user,  user, 
            app_name(), 'INSERT', not_number, not_text, 
            not_type, not_urgent, not_senton, not_sentby, not_expires, 
            not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, 
            last_updatedby, last_updatedatetime, autonote, not_text_large, 
            not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, 
            not_number_copied_from, not_tmsend 
       from notes 
      where not_number in (select distinct not_number from inserted) 
        and not_number not in (select distinct not_number from deleted)
-- capture previous values to updated notes (notes in the deleted table and inserted table)
insert into notes_audit (audit_datetime,  audit_loguser,  audit_dbuser, 
                         audit_application, audit_type, not_number, not_text, 
                         not_type, not_urgent, not_senton, not_sentby, not_expires, 
                         not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, 
                         last_updatedby, last_updatedatetime, autonote, 
--not_text_large, 
                         not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, 
                         not_number_copied_from, not_tmsend)
     select getdate(),  system_user,  user, 
            app_name(), 'UPDATE', not_number, not_text, 
            not_type, not_urgent, not_senton, not_sentby, not_expires, 
            not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, 
            last_updatedby, last_updatedatetime, autonote, 
--not_text_large, 
            not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, 
            not_number_copied_from, not_tmsend 
       from deleted 
      where not_number in (select distinct not_number from deleted) 
        and not_number in (select distinct not_number from inserted) 

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--DPH PTS 30211
DECLARE @daystoadd int

select 	@daystoadd = isNull(gi_integer1,0)
from	generalinfo
where	gi_name = 'NUMBEROFDAYSFORNOTEEXP'

--SLM PTS 39478 
Select @DoNotUseCopyProcAsUser = Upper(isnull(gi_string1,'N')) from generalinfo where gi_name = 'DoNotUseCopyProcAsUser'

IF isNull(@daystoadd,0) > 0 and (select Max(inserted.not_expires) from inserted) >= '20491231 23:59'
 BEGIN
--	UPDATE 	notes  
--	SET 	last_updatedby = @tmwuser, 
--		last_updatedatetime = getdate(),
--		not_expires = dateadd(dd, @daystoadd, getdate())
--	FROM 	inserted
--	WHERE 	inserted.not_number = notes.not_number

	UPDATE 	notes  
	SET 	last_updatedby = Case @DoNotUseCopyProcAsUser When 'Y' Then notes.last_updatedby Else @tmwuser End, 
			last_updatedatetime = getdate()
--KPM pts 48225 3/11/2010 moved Note Expiration logic into the open of the window.
--			not_expires = dateadd(dd, @daystoadd, getdate())
	FROM 	inserted
	WHERE 	inserted.not_number = notes.not_number				  				
 END
ELSE
 BEGIN
	UPDATE 	notes  
	SET 	last_updatedby = @tmwuser, 
		last_updatedatetime = getdate()
	  FROM 	inserted
	 WHERE 	inserted.not_number = notes.not_number
	and  (inserted.last_updatedby is null or inserted.last_updatedby = '')
 END
--DPH PTS 30211

IF (SELECT  COUNT(*)
      FROM  inserted
     WHERE  ntb_table = 'tractorprofile') > 0
BEGIN
	UPDATE	tractorprofile
	   SET	trc_note_date = (SELECT MAX(not_expires)
				   FROM notes
			 	  WHERE ntb_table = 'tractorprofile' AND
					nre_tablekey = i.nre_tablekey AND
					not_urgent <> 'A'),
	        trc_alert_date = (SELECT MAX(not_expires)
				    FROM notes
				   WHERE ntb_table = 'tractorprofile' AND
					 nre_tablekey = i.nre_tablekey AND
					 not_urgent = 'A')
  	  FROM	tractorprofile tp, inserted i
	 WHERE	tp.trc_number = i.nre_tablekey AND
		i.ntb_table = 'tractorprofile' 
END
ELSE
BEGIN
	IF (SELECT  COUNT(*)
	      FROM  deleted
	     WHERE  ntb_table = 'tractorprofile') > 0
	BEGIN
		UPDATE	tractorprofile
		   SET	trc_note_date = (SELECT  MAX(not_expires)
					   FROM  notes
				 	  WHERE  ntb_table = 'tractorprofile' AND
						 nre_tablekey = d.nre_tablekey AND
						 not_urgent <> 'A'),
		        trc_alert_date = (SELECT MAX(not_expires)
					    FROM notes
					   WHERE ntb_table = 'tractorprofile' AND
						 nre_tablekey = d.nre_tablekey AND
						 not_urgent = 'A')
	  	  FROM	tractorprofile tp, deleted d
		 WHERE	tp.trc_number = d.nre_tablekey AND
			d.ntb_table = 'tractorprofile' 	
	END
END


--vmj2+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())

-- RE - 12/02/03 - PTS #20069
--if @ls_audit <> 'Y'
--	return

--All code below this is for expedite_audit..
--vmj2-

--vmj1+
select	@li_insert_count = count(*)
  from	inserted
select	@li_delete_count = count(*)
  from	deleted

if @li_delete_count = 0
begin
	--This is an INSERT..
	-- RE - 12/02/03 - PTS #20069 BEGIN
	update	notes  
	   set	last_updatedby = @tmwuser, 
			last_updatedatetime = getdate()
   	  from	inserted
   	 where	(inserted.not_number = notes.not_number) and
			(inserted.last_updatedby is null or inserted.last_updatedby = '')

	if @ls_audit <> 'Y'
		return
	-- RE - 12/02/03 - PTS #20069 END

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

	  select 
			-- RE - 12/02/03 - PTS #20069 BEGIN
			case rtrim(ntb_table)
				when 'orderheader' then convert(integer, nre_tablekey)
				else 0
			end
			-- RE - 12/02/03 - PTS #20069 END
			,@tmwuser
			,'Notes inserted'
			,getdate()
			,left('UrgentIndc=' + isnull(not_urgent, 'null') + ', Text=' + 
				isnull('"' + not_text + '"', null), 255)
			,convert(varchar(20), not_number)
			-- RE - 12/02/03 - PTS #20069 BEGIN
			,case rtrim(ntb_table)
				when 'movement' then convert(integer, nre_tablekey)
				else 0
			 end
			-- RE - 12/02/03 - PTS #20069 END
			,0
			,'notes'
	  from	inserted

	return
end


if @li_insert_count = 0
begin
	--This is a DELETE..
	-- RE - 12/02/03 - PTS #20069 BEGIN
	if @ls_audit <> 'Y'
		return
	-- RE - 12/02/03 - PTS #20069 END

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
	  select 
			-- RE - 12/02/03 - PTS #20069 BEGIN
			case rtrim(ntb_table)
				when 'orderheader' then convert(integer, nre_tablekey)
				else 0
			end
			-- RE - 12/02/03 - PTS #20069 END
			,@tmwuser
			,'Notes deleted'
			,getdate()
			,null
			,convert(varchar(20), not_number)
			-- RE - 12/02/03 - PTS #20069 BEGIN
			,case rtrim(ntb_table)
				when 'movement' then convert(integer, nre_tablekey)
				else 0
			 end
			-- RE - 12/02/03 - PTS #20069 END
			,0
			,'notes'
	  from	deleted

	return
end

--If we get here, it's an update..
select	@ldt_updated_dt = getdate()
		,@ls_user = @tmwuser

-- RE - 12/02/03 - PTS #20069 BEGIN
update	notes  
   set	last_updatedby = @ls_user, 
		last_updatedatetime = @ldt_updated_dt
  from	inserted
 where	(inserted.not_number = notes.not_number) and
		(inserted.last_updatedby is null or inserted.last_updatedby = '')

if @ls_audit <> 'Y'
	return
-- RE - 12/02/03 - PTS #20069 END

if update(not_urgent)
begin
	/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		to represent NULL in comparisons..	*/
--CJB -- 44833 -- Do not update the expedite_audit table, always perform an insert.  This was removed for performance purposes.
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', UrgentIndc ' + 
--							ltrim(rtrim(isnull(d.not_urgent, 'null'))) + ' -> ' + 
--							ltrim(rtrim(isnull(i.not_urgent, 'null')))
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.not_number = d.not_number
--		and	isnull(i.not_urgent, 'nU1L') <> isnull(d.not_urgent, 'nU1L')
--		-- RE - 12/02/03 - PTS #20069 BEGIN
--		and	ea.ord_hdrnumber = case rtrim(i.ntb_table)
--								when 'orderheader' then convert(integer, i.nre_tablekey)
--								else 0
--				  			   end
--		-- RE - 12/02/03 - PTS #20069 END
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'Notes update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.not_number)
--		-- RE - 12/02/03 - PTS #20069 BEGIN
--		and	ea.mov_number = case rtrim(i.ntb_table)
--								when 'movement' then convert(integer, i.nre_tablekey)
--								else 0
--							end
--		-- RE - 12/02/03 - PTS #20069 END
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'notes'

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
	  select 
			-- RE - 12/02/03 - PTS #20069 BEGIN
			case rtrim(i.ntb_table)
				when 'orderheader' then convert(integer, i.nre_tablekey)
				else 0
			end
			-- RE - 12/02/03 - PTS #20069 END
			,@ls_user
			,'Notes update'
			,@ldt_updated_dt
			,'UrgentIndc ' + ltrim(rtrim(isnull(d.not_urgent, 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull(i.not_urgent, 'null')))
			,convert(varchar(20), i.not_number)
			-- RE - 12/02/03 - PTS #20069 BEGIN
			,case rtrim(i.ntb_table)
				when 'movement' then convert(integer, i.nre_tablekey)
				else 0
			 end
			-- RE - 12/02/03 - PTS #20069 END
			,0
			,'notes'
	  from	deleted d
			,inserted i
	  where	i.not_number = d.not_number
		and	isnull(i.not_urgent, 'nU1L') <> isnull(d.not_urgent, 'nU1L')
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--  			   from	expedite_audit ea2
--			  where	ea2.updated_by = @ls_user
--				-- RE - 12/02/03 - PTS #20069 BEGIN
--				and	ea2.ord_hdrnumber = case rtrim(i.ntb_table)
--											when 'orderheader' then convert(integer, i.nre_tablekey)
--											else 0
--						  			    end
--				-- RE - 12/02/03 - PTS #20069 END
--				and	ea2.activity = 'Notes update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.not_number)
--				-- RE - 12/02/03 - PTS #20069 BEGIN
--				and	ea2.mov_number = case rtrim(i.ntb_table)
--										when 'movement' then convert(integer, i.nre_tablekey)
--										else 0
--									end
--				-- RE - 12/02/03 - PTS #20069 END
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'notes')
CJB END -- 44833*/
end


if update(not_text)
begin
	/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
		to represent NULL in comparisons..	*/
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = left(ea.update_note + ', Text ' + 
--							ltrim(rtrim(isnull('"' + d.not_text + '"', 'null'))) + ' -> ' + 
--							ltrim(rtrim(isnull('"' + i.not_text + '"', 'null'))), 255)
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.not_number = d.not_number
--		and	isnull(i.not_text, 'nU1L') <> isnull(d.not_text, 'nU1L')
--		-- RE - 12/02/03 - PTS #20069 BEGIN
--		and	ea.ord_hdrnumber = case rtrim(i.ntb_table)
--								when 'orderheader' then convert(integer, i.nre_tablekey)
--								else 0
--				  			   end
--		-- RE - 12/02/03 - PTS #20069 END
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'Notes update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.not_number)
--		-- RE - 12/02/03 - PTS #20069 BEGIN
--		and	ea.mov_number = case rtrim(i.ntb_table)
--								when 'movement' then convert(integer, i.nre_tablekey)
--								else 0
--							end
--		-- RE - 12/02/03 - PTS #20069 END
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'notes'
CJB END -- 44833*/

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
	  select 
			-- RE - 12/02/03 - PTS #20069 BEGIN
			case rtrim(i.ntb_table)
				when 'orderheader' then convert(integer, i.nre_tablekey)
				else 0
			end
			-- RE - 12/02/03 - PTS #20069 END
			,@ls_user
			,'Notes update'
			,@ldt_updated_dt
			,left('Text ' + ltrim(rtrim(isnull('"' + d.not_text + '"', 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull('"' + i.not_text + '"', 'null'))), 255)
			,convert(varchar(20), i.not_number)
			-- RE - 12/02/03 - PTS #20069 BEGIN
			,case rtrim(i.ntb_table)
				when 'movement' then convert(integer, i.nre_tablekey)
				else 0
			 end
			-- RE - 12/02/03 - PTS #20069 END
			,0
			,'notes'
	  from	deleted d
			,inserted i
	  where	i.not_number = d.not_number
		and	isnull(i.not_text, 'nU1L') <> isnull(d.not_text, 'nU1L')
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.updated_by = @ls_user
--				-- RE - 12/02/03 - PTS #20069 BEGIN
--				and	ea2.ord_hdrnumber = case rtrim(i.ntb_table)
--											when 'orderheader' then convert(integer, i.nre_tablekey)
--											else 0
--						  			    end
--				-- RE - 12/02/03 - PTS #20069 END
--				and	ea2.activity = 'Notes update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.not_number)
--				-- RE - 12/02/03 - PTS #20069 BEGIN
--				and	ea2.mov_number = case rtrim(i.ntb_table)
--										when 'movement' then convert(integer, i.nre_tablekey)
--										else 0
--									end
--				-- RE - 12/02/03 - PTS #20069 END
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'notes')
CJB END -- 44833 */
end
--vmj1-

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [dbo].[tr_alta_notas_tmw_JR]  ON [dbo].[notes] 
AFTER INSERT
AS

begin
 --select * from notes where nre_tablekey = '591163'

Set Nocount on 

declare 
	@V_not_number integer, 
	@V_ntb_table char(18), 
	@V_nre_tablekey char(18),
	@V_not_type varchar(6),
	@V_not_text varchar(254),
	@V_ord_status	varchar(6), 
	@V_ord_invoicestatus varchar(6),
	@V_not_viewlevel	varchar(6)




Select 
	@V_not_number	= I.not_number,
	@V_ntb_table	= I.ntb_table,
	@V_nre_tablekey = I.nre_tablekey,
	@V_not_type		= I.not_type,
	@V_not_text		= I.not_text ,
	@V_not_viewlevel= I.not_viewlevel
From INSERTED I

-- 1er. valida el tipo de nota

IF @V_not_viewlevel ='ERMC' OR @V_not_viewlevel = 'ERFA'
Begin --1. tipo de nota
		-- valida que sea una nota pegada a la orden
	IF @V_ntb_table = 'orderheader'
		begin --2. num de orden
			-- obtiene los status de la orden
				Select @V_ord_status = ord_status,
				@V_ord_invoicestatus = ord_invoicestatus 
				from orderheader 
				Where ord_number = @V_nre_tablekey;

			-- valida que el status de la orden este en AVL 
			IF @V_not_viewlevel ='ERMC'
				begin
					IF @V_ord_invoicestatus <> 'AVL'
						begin
							select @V_not_text = right('Es nec que el status fac sea AVL  ' + isNull(@V_not_text,'') ,240)
							--actualiza la nota 

							update notes set not_text = @V_not_text where not_number = @V_not_number;
							--commit;
						end 

					-- Si esta en AVL cambia el status a AMC

					IF  @V_ord_invoicestatus = 'AVL'
						begin
							update orderheader set ord_invoicestatus ='AMC' Where ord_number = @V_nre_tablekey;
							--commit;
						end 
				end
			--proceso cuando MC lo regresa a FAC

			IF @V_not_viewlevel ='ERFA'
				begin
					IF @V_ord_invoicestatus <> 'AMC'
						begin
							select @V_not_text = right('Es nec que el status fac sea AMC  ' + isNull(@V_not_text,'') ,240)
							--actualiza la nota 

							update notes set not_text = @V_not_text where not_number = @V_not_number;
							--commit;
						end 

					-- Si esta en AVL cambia el status a AMC

					IF  @V_ord_invoicestatus = 'AMC'
						begin
							update orderheader set ord_invoicestatus ='AVL' Where ord_number = @V_nre_tablekey;
							--commit;
						end 
				end
	end -- 2 num de orden
end -- 1 tipo de nota
end  -- principal

GO
CREATE UNIQUE CLUSTERED INDEX [pk_number] ON [dbo].[notes] ([not_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tblkey_tbl_exp] ON [dbo].[notes] ([nre_tablekey], [ntb_table], [not_expires], [not_urgent]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_key] ON [dbo].[notes] ([ntb_table], [nre_tablekey]) INCLUDE ([not_type], [not_urgent], [not_expires]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notes] TO [public]
GO
GRANT INSERT ON  [dbo].[notes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notes] TO [public]
GO
GRANT SELECT ON  [dbo].[notes] TO [public]
GO
GRANT UPDATE ON  [dbo].[notes] TO [public]
GO
