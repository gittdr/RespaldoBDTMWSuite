CREATE TABLE [dbo].[cmpemailmsg]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mail_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updateddate] [datetime] NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[stp_number] [int] NULL,
[events] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contact_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msgtype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstlastflags] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailertractor] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create trigger [dbo].[dt_cmpemailmsg] on [dbo].[cmpemailmsg] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/*	Trigger dt_cmpemailmsg inserts a fingerprinting entry (table expedite_audit) whenever a row is
	deleted from cmpemailmsg.  Jack said that whenever an email/fax is attempted, the row is deleted
	from this table; hence it's a good triggering mechanism.

	Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------------
	08/15/2001	Vern Jewett		(none)	Original, for PTS 11785, CTX Item #47.
	02/28/2002	Vern Jewett		vmj1	Don't store an audit row unless the feature is turned on.
*/

declare	@ls_audit	varchar(1)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--vmj1+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
	--vmj1-

	--Insert expedite_audit row..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,mov_number
			,lgh_number
			,join_to_table_name
			,key_value)
	  select isnull(ord_hdrnumber, 0)
			,@tmwuser
			,(case type when 'E' then 'Email' else 'Fax' end) + ' sent'
			,updateddate
			,'Company=' + cmp_id + ', email=' + email_address + ', MsgType=' + msgtype
			,isnull(mov_number, 0)
			,0
			,'cmpemaillog'
			,cmp_id + ', ' + convert(varchar(90), getdate(), 120)
	  from	deleted

GO
GRANT DELETE ON  [dbo].[cmpemailmsg] TO [public]
GO
GRANT INSERT ON  [dbo].[cmpemailmsg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cmpemailmsg] TO [public]
GO
GRANT SELECT ON  [dbo].[cmpemailmsg] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmpemailmsg] TO [public]
GO
