CREATE TABLE [dbo].[StopSchedules]
(
[sch_id] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NOT NULL,
[sch_BillToContactMade] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationContactMade] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_CreatedOn] [datetime] NOT NULL,
[sch_LastUpdateBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_LastUpdateOn] [datetime] NOT NULL,
[sch_DriverTargetDate] [datetime] NOT NULL,
[lgh_number] [int] NULL,
[sch_BillToContactMadeDate] [datetime] NULL,
[sch_LocationContactMadeDate] [datetime] NULL,
[sch_DriverTargetEndDate] [datetime] NULL,
[ce_id] [int] NULL,
[sch_contactname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_reasoncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_locationid] [int] NULL,
[sch_locationcontactname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_BillToEmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_BillToPhone1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_BillToPhone1Ext] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_BillToPhone2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_BillToPhone2Ext] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_BillToFaxNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationEmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationPhone1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationPhone1Ext] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationPhone2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationPhone2Ext] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationFaxNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_AdHocBillToContact] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_AdHocLocationContact] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_reasonlatecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_ontime] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_lateTractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_lockScheduleDate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itutdtStopSchedules] ON [dbo].[StopSchedules]
FOR DELETE,UPDATE,INSERT   
AS

SET NOCOUNT ON

insert into StopSchedulesHistory(
		sch_id,
		sch_BillToContactMade,
		sch_LocationContactMade,
		sch_CreatedOn,
		sch_CreatedBy,
		sch_DriverTargetDate,
		sch_BillToContactMadeDate,
		sch_LocationContactMadeDate,
		sch_DriverTargetEndDate,
		ce_id,
		sch_contactname,
		sch_reasoncode,
		sch_comment,
		ce_locationid,
		sch_locationcontactname,
		sch_lateTractor,
		sch_ontime,
		sch_LastUpdateBy,
		sch_LastUpdateOn,
		sch_reasonlatecode)
select	sch_id,
		sch_BillToContactMade,
		sch_LocationContactMade,
		sch_CreatedOn,
		sch_CreatedBy,
		sch_DriverTargetDate,
		sch_BillToContactMadeDate,
		sch_LocationContactMadeDate,
		sch_DriverTargetEndDate,
		ce_id,
		sch_contactname,
		sch_reasoncode,
		sch_comment,
		ce_locationid,
		sch_locationcontactname,
		sch_lateTractor,
		sch_ontime,
		sch_LastUpdateBy,
		sch_LastUpdateOn,
		sch_reasonlatecode
  from inserted
  
--AVANE - Auditing for insert/update (if turned on)
declare @ls_audit char, @ls_user varchar(20), @ldt_updated_dt datetime

select @ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
from generalinfo g1
where g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select max(g2.gi_datein)
						from generalinfo g2
						where g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
							
if @ls_audit = 'Y'
begin
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

	select	@ls_user = @tmwuser
			,@ldt_updated_dt = getdate()
		
	--inserts
	if exists(select top 1 sch_id from inserted)
	begin
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
		  select isnull(lh.ord_hdrnumber, 0)
				,@ls_user
				,'StopSchedules insert'
				,@ldt_updated_dt
				,'sch_id ' + CONVERT(varchar(20), i.sch_id) + ' created for stp ' + CONVERT(varchar(20), i.stp_number)
				,convert(varchar(20), i.sch_id)
				,isnull(lh.mov_number, 0)
				,isnull(i.lgh_number, 0)
				,'StopSchedules'
		  from inserted i
			join legheader lh (nolock) on lh.lgh_number = i.lgh_number
			where not exists(select top 1 sch_id from deleted d where d.sch_id = i.sch_id)
	end 
	
	--updates
	if exists(select top 1 sch_id from deleted)
	begin
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
		  select isnull(lh.ord_hdrnumber, 0)
				,@ls_user
				,'StopSchedules update'
				,@ldt_updated_dt
				,'sch_id ' + CONVERT(varchar(20), i.sch_id) + ' updated for stp ' + CONVERT(varchar(20), i.stp_number)
				,convert(varchar(20), i.sch_id)
				,isnull(lh.mov_number, 0)
				,isnull(i.lgh_number, 0)
				,'StopSchedules'
		  from inserted i
		  	join deleted d on d.sch_id = i.sch_id
			join legheader lh (nolock) on lh.lgh_number = i.lgh_number
	end 
end


	

--go
GO
ALTER TABLE [dbo].[StopSchedules] ADD CONSTRAINT [pk_StopSchedules] PRIMARY KEY CLUSTERED ([sch_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_StopSchedules_stp_number] ON [dbo].[StopSchedules] ([stp_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopSchedules] ADD CONSTRAINT [fk_StopSchedule_to_Stops] FOREIGN KEY ([stp_number]) REFERENCES [dbo].[stops] ([stp_number])
GO
GRANT DELETE ON  [dbo].[StopSchedules] TO [public]
GO
GRANT INSERT ON  [dbo].[StopSchedules] TO [public]
GO
GRANT SELECT ON  [dbo].[StopSchedules] TO [public]
GO
GRANT UPDATE ON  [dbo].[StopSchedules] TO [public]
GO
