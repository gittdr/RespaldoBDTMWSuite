CREATE TABLE [dbo].[Timeline_header]
(
[tlh_number] [int] NOT NULL IDENTITY(1, 1),
[tlh_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tlh_effective] [datetime] NULL,
[tlh_expires] [datetime] NULL,
[tlh_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tlh_plant] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tlh_dock] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_jittime] [int] NULL,
[tlh_leaddays] [int] NULL,
[tlh_leadbasis] [int] NULL,
[tlh_sequence] [int] NULL,
[tlh_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_sunday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_saturday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_timezone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_SubrouteDomicle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_DOW] [int] NULL,
[tlh_specialist] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_updatedon] [datetime] NULL,
[tlh_effective_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_timeline_header] ON [dbo].[Timeline_header] FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @li_insert_count int,
	@li_delete_count int,
	@tlh_group_identity int

SELECT	@li_insert_count = count(*)
  FROM	inserted
SELECT	@li_delete_count = count(*)
  FROM	deleted


SELECT 	@tlh_group_identity = max(tlh_group_identity) + 1
FROM	timeline_header_history

If IsNull(@tlh_group_identity, '') = ''
 BEGIN
	Select @tlh_group_identity = 1
 END

if @li_delete_count <> 0 and @li_insert_count <> 0
 BEGIN
	INSERT INTO timeline_header_history (
		tlh_group_identity,
		tlh_number,
		tlh_name,
		tlh_effective,
		tlh_expires,
		tlh_supplier,
		tlh_plant,
		tlh_dock,
		tlh_jittime,
		tlh_leaddays,
		tlh_leadbasis,
		tlh_sequence,
		tlh_direction,
		tlh_sunday,
		tlh_saturday,
		tlh_branch,
		tlh_timezone,
		tlh_SubrouteDomicile,        
		tlh_DOW,
		tlh_specialist,
		tlh_updatedby,
		tlh_updatedon)
	SELECT 	@tlh_group_identity,
		tlh_number,
		tlh_name,
		tlh_effective,
		tlh_expires,
		tlh_supplier,
		tlh_plant,
		tlh_dock,
		tlh_jittime,
		tlh_leaddays,
		tlh_leadbasis,
		tlh_sequence,
		tlh_direction,
		tlh_sunday,
		tlh_saturday,
		tlh_branch,
		tlh_timezone,
		tlh_SubrouteDomicle,
		tlh_DOW,
		tlh_specialist,
		tlh_updatedby,
		tlh_updatedon
	FROM 	Deleted
 END

RETURN

GO
CREATE NONCLUSTERED INDEX [idx_tlh_id] ON [dbo].[Timeline_header] ([tlh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Timeline_header] TO [public]
GO
GRANT INSERT ON  [dbo].[Timeline_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Timeline_header] TO [public]
GO
GRANT SELECT ON  [dbo].[Timeline_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[Timeline_header] TO [public]
GO
