CREATE TABLE [dbo].[partorder_header]
(
[poh_identity] [int] NOT NULL IDENTITY(1, 1),
[poh_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_plant] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_dock] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_jittime] [int] NULL,
[poh_sequence] [int] NULL,
[poh_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_datereceived] [datetime] NOT NULL,
[poh_pickupdate] [datetime] NULL,
[poh_deliverdate] [datetime] NULL,
[poh_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_updatedon] [datetime] NULL,
[poh_comment] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_release] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[poh_scanned] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_timelineid] [int] NULL,
[poh_tlmod_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_supplieralias] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_skiptrigger] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_effective_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_checksheetstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_checksheetdate] [datetime] NULL,
[poh_srf_recieve] [datetime] NULL,
[poh_upotype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_uporoute] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poh_xdock_event] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_partorder_header] ON [dbo].[partorder_header] FOR UPDATE, DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @li_insert_count int,
	@li_delete_count int,
	@poh_group_identity int

SELECT	@li_insert_count = count(*)
  FROM	inserted
SELECT	@li_delete_count = count(*)
  FROM	deleted


SELECT 	@poh_group_identity = max(poh_group_identity) + 1
FROM	partorder_header_history

If IsNull(@poh_group_identity, '') = ''
 BEGIN
	Select @poh_group_identity = 1
 END

if @li_delete_count <> 0
 BEGIN
	INSERT INTO partorder_header_history (
		poh_group_identity,
		poh_identity,
		poh_branch,
		poh_supplier,
		poh_plant,
		poh_dock,
		poh_jittime,
		poh_sequence,
		poh_reftype,
		poh_refnum,
		poh_datereceived,
		poh_pickupdate,
		poh_deliverdate,
		poh_updatedby,
		poh_updatedon,
		poh_comment,
		poh_type,
		poh_release,
		poh_status,
		poh_scanned,
		poh_timelineid,
		poh_supplieralias)
	SELECT 	@poh_group_identity,
		poh_identity,
		poh_branch,
		poh_supplier,
		poh_plant,
		poh_dock,
		poh_jittime,
		poh_sequence,
		poh_reftype,
		poh_refnum,
		poh_datereceived,
		poh_pickupdate,
		poh_deliverdate,
		poh_updatedby,
		poh_updatedon,
		poh_comment,
		poh_type,
		poh_release,
		poh_status,
		poh_scanned,
		poh_timelineid,
		poh_supplieralias
	FROM 	Deleted
	WHERE	poh_skiptrigger = 'N'
	OR	@li_insert_count = 0

	IF @li_insert_count <> 0 
		UPDATE	partorder_header
		SET 	partorder_header.poh_skiptrigger = 'N'
		FROM	inserted i INNER JOIN deleted d
		ON	i.poh_identity = d.poh_identity
		WHERE 	partorder_header.poh_identity = i.poh_identity
		AND	isnull(partorder_header.poh_skiptrigger,'Y') <> 'N'
		AND	isnull(i.poh_skiptrigger, 'Y') = isnull(d.poh_skiptrigger, 'Y')
 END



RETURN

GO
CREATE NONCLUSTERED INDEX [idx_poh_branch] ON [dbo].[partorder_header] ([poh_branch], [poh_supplier]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_del] ON [dbo].[partorder_header] ([poh_deliverdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_id] ON [dbo].[partorder_header] ([poh_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_pu] ON [dbo].[partorder_header] ([poh_pickupdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_refnum] ON [dbo].[partorder_header] ([poh_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_poh_supplier] ON [dbo].[partorder_header] ([poh_supplier]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_header] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_header] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_header] TO [public]
GO
