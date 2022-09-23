CREATE TABLE [dbo].[paperwork]
(
[abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pw_received] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NOT NULL,
[timestamp] [timestamp] NULL,
[pw_dt] [datetime] NULL,
[last_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateddatetime] [datetime] NULL,
[lgh_number] [int] NULL,
[pw_imaged] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__paperwork__pw_im__4749136D] DEFAULT ('N'),
[pw_ident] [int] NOT NULL IDENTITY(1, 1),
[Mov_Number] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/* PTS 16665 - DJM - Added lgh_number to the where clause.		
PTS 28369 DPETE If pw_imaged is updated and not pw_received, do not set user
PTS 34647 DPETE changed imaging index stored procs to update last user and date, don;t so here if already done/
PTS 35809 JLB moved logic from 32790 from event trigger to this table
PTS 43955 DPETE GSTSS has custom code in this trigger from earlier , they asked to make changes to it.
PTS 41371 vjh changes coded by client GSTSS 
*/

CREATE TRIGGER [dbo].[iut_paperwork] ON [dbo].[paperwork] FOR INSERT,UPDATE AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

BEGIN

	--JLB PTS 35809
	Declare @ordereventexport char(1), @pw_received char(1), @stp_number int, @ord_billto varchar(8) 
	Declare @stp_departuredate datetime, @ord_hdrnumber int, @rowcount int, @pw_count int
	DECLARE @ord_total_charge varchar(255),@stp_yardexitdate datetime  --PTS43955

	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output


	If Update(last_updatedby ) and update (last_updateddatetime)
		--
		UPDATE	paperwork
		SET		last_updatedby = isnull(inserted.last_updatedby, @tmwuser), 
				last_updateddatetime = isnull(inserted.last_updateddatetime, getdate())
		FROM	inserted
		WHERE	(inserted.ord_hdrnumber = paperwork.ord_hdrnumber) AND
				(inserted.abbr = paperwork.abbr) AND
				(inserted.lgh_number = paperwork.lgh_number)AND
				(inserted.Mov_Number = paperwork.Mov_Number)
	else
		UPDATE	paperwork
		SET		last_updatedby = @tmwuser, 
				last_updateddatetime = getdate()
		FROM	inserted
		WHERE	(inserted.ord_hdrnumber = paperwork.ord_hdrnumber) AND
				(inserted.abbr = paperwork.abbr) AND
				(inserted.lgh_number = paperwork.lgh_number)
	
END

GO
CREATE NONCLUSTERED INDEX [IX_paperwork_lgh_number] ON [dbo].[paperwork] ([lgh_number]) INCLUDE ([Mov_Number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_mov_number] ON [dbo].[paperwork] ([Mov_Number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_paperwork_OrdHdrNumber_Abbr_Received_Imaged] ON [dbo].[paperwork] ([ord_hdrnumber]) INCLUDE ([abbr], [pw_received], [pw_imaged]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ord_lgh_abbr_move] ON [dbo].[paperwork] ([ord_hdrnumber], [lgh_number], [abbr], [Mov_Number]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_pw_ident] ON [dbo].[paperwork] ([pw_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_paperwork_pw_ident] ON [dbo].[paperwork] ([pw_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paperwork] TO [public]
GO
GRANT INSERT ON  [dbo].[paperwork] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paperwork] TO [public]
GO
GRANT SELECT ON  [dbo].[paperwork] TO [public]
GO
GRANT UPDATE ON  [dbo].[paperwork] TO [public]
GO
