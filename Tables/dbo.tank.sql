CREATE TABLE [dbo].[tank]
(
[tank_nbr] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tank_loc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tank_model_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_highdip] [smallint] NULL,
[tank_lowdip] [smallint] NULL,
[tank_warndip] [smallint] NULL,
[tank_dip_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_capacity] [int] NULL,
[tank_cap_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_type1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_inuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE              trigger [dbo].[dt_tank]
on [dbo].[tank]
for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 * 
 * NAME:
 * dbo.dt_tank
 *
 * TYPE:
 * Trigger|D] 
 *
 * DESCRIPTION:
 * This procedure deletes tankdiphistory and diplog records for deleted tanks
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * none
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * none

 * 
 * REVISION HISTORY:
 * 09/26/05.01 ? PTS29952 - DPETE ? Pauls Hauling reports foreigh key constraint when trying to 
 *              delete a tank record
 *
 **/




Delete from tankdiphistory 
where tankdiphistory.tank_nbr in (Select tank_nbr from deleted)

Delete from diplog
Where diplog.tank_nbr in (Select tank_nbr from deleted)


GO
ALTER TABLE [dbo].[tank] ADD CONSTRAINT [PK_tank] PRIMARY KEY CLUSTERED ([tank_nbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_tank_tank_model_id] ON [dbo].[tank] ([tank_model_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tank] ADD CONSTRAINT [tank_tank_model_id_FK] FOREIGN KEY ([tank_model_id]) REFERENCES [dbo].[tankmodel] ([model_id])
GO
GRANT DELETE ON  [dbo].[tank] TO [public]
GO
GRANT INSERT ON  [dbo].[tank] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tank] TO [public]
GO
GRANT SELECT ON  [dbo].[tank] TO [public]
GO
GRANT UPDATE ON  [dbo].[tank] TO [public]
GO
