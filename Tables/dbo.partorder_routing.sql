CREATE TABLE [dbo].[partorder_routing]
(
[por_identity] [int] NOT NULL IDENTITY(1, 1),
[poh_identity] [int] NOT NULL,
[por_master_ordhdr] [int] NULL,
[por_ordhdr] [int] NULL,
[por_origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_begindate] [datetime] NULL,
[por_destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_enddate] [datetime] NULL,
[por_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[por_updatedon] [datetime] NULL,
[por_sequence] [int] NULL,
[por_trl_unload_dt] [datetime] NULL,
[por_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_partorder_routing] ON [dbo].[partorder_routing] FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

	UPDATE partorder_header
	SET poh_status = '10'
	FROM inserted
	WHERE inserted.poh_identity = partorder_header.poh_identity
	  AND poh_status = '950'

--	LOR	PTS# 32269
DECLARE @li_insert_count int,
		@por_group_identity int

SELECT	@li_insert_count = count(*) FROM inserted

SELECT 	@por_group_identity = max(por_group_identity) + 1
FROM	partorder_routing_history

If IsNull(@por_group_identity, '') = ''
	Select @por_group_identity = 1

if @li_insert_count <> 0
 BEGIN
	INSERT INTO partorder_routing_history (
		por_group_identity,
		por_identity,
		poh_identity,
		por_master_ordhdr,
		por_ordhdr,
		por_origin,
		por_begindate,
		por_destination,
		por_enddate,
		por_updatedby,
		por_updatedon)
	SELECT 	@por_group_identity,
		por_identity,
		poh_identity,
		por_master_ordhdr,
		por_ordhdr,
		por_origin,
		por_begindate,
		por_destination,
		por_enddate,
		por_updatedby,
		por_updatedon
	FROM 	inserted
 END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_partorder_routing] ON [dbo].[partorder_routing] FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @li_insert_count int,
	@li_delete_count int,
	@por_group_identity int

SELECT	@li_insert_count = count(*)
  FROM	inserted
SELECT	@li_delete_count = count(*)
  FROM	deleted


SELECT 	@por_group_identity = max(por_group_identity) + 1
FROM	partorder_routing_history

If IsNull(@por_group_identity, '') = ''
 BEGIN
	Select @por_group_identity = 1
 END

if @li_delete_count <> 0 and @li_insert_count <> 0
 BEGIN
	INSERT INTO partorder_routing_history (
		por_group_identity,
		por_identity,
		poh_identity,
		por_master_ordhdr,
		por_ordhdr,
		por_origin,
		por_begindate,
		por_destination,
		por_enddate,
		por_updatedby,
		por_updatedon)
	SELECT 	@por_group_identity,
		por_identity,
		poh_identity,
		por_master_ordhdr,
		por_ordhdr,
		por_origin,
		por_begindate,
		por_destination,
		por_enddate,
		por_updatedby,
		por_updatedon
	FROM 	Deleted
 END

RETURN

GO
CREATE NONCLUSTERED INDEX [por_poh_id] ON [dbo].[partorder_routing] ([poh_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_por_id] ON [dbo].[partorder_routing] ([por_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_por_mstord] ON [dbo].[partorder_routing] ([por_master_ordhdr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_por_ord] ON [dbo].[partorder_routing] ([por_ordhdr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_routing] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_routing] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_routing] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_routing] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_routing] TO [public]
GO
