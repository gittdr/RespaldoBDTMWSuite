CREATE TABLE [dbo].[ltl_routeheader]
(
[lrh_id] [int] NOT NULL IDENTITY(1, 1),
[lrh_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lrh_avl_sun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_sun] DEFAULT ('Y'),
[lrh_avl_mon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_mon] DEFAULT ('Y'),
[lrh_avl_tue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_tue] DEFAULT ('Y'),
[lrh_avl_wed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_wed] DEFAULT ('Y'),
[lrh_avl_thu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_thu] DEFAULT ('Y'),
[lrh_avl_fri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_fri] DEFAULT ('Y'),
[lrh_avl_sat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_avl_sat] DEFAULT ('Y'),
[lrh_max_orders] [int] NOT NULL CONSTRAINT [df_ltl_routeheader_max_orders] DEFAULT (0),
[lrh_max_count] [decimal] (9, 2) NOT NULL CONSTRAINT [df_ltl_routeheader_max_count] DEFAULT (0),
[lrh_max_count_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_max_count_uom] DEFAULT ('UNK'),
[lrh_max_weight] [float] NOT NULL CONSTRAINT [df_ltl_routeheader_max_weight] DEFAULT (0),
[lrh_max_weight_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_max_weight_uom] DEFAULT ('UNK'),
[lrh_max_volume] [float] NOT NULL CONSTRAINT [df_ltl_routeheader_max_volume] DEFAULT (0),
[lrh_max_volume_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_max_volume_uom] DEFAULT ('UNK'),
[lrh_warn_orders] [int] NOT NULL CONSTRAINT [df_ltl_routeheader_warn_orders] DEFAULT (0),
[lrh_warn_count] [decimal] (9, 2) NOT NULL CONSTRAINT [df_ltl_routeheader_warn_count] DEFAULT (0),
[lrh_warn_count_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_warn_count_uom] DEFAULT ('UNK'),
[lrh_warn_weight] [float] NOT NULL CONSTRAINT [df_ltl_routeheader_warn_weight] DEFAULT (0),
[lrh_warn_weight_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_warn_weight_uom] DEFAULT ('UNK'),
[lrh_warn_volume] [float] NOT NULL CONSTRAINT [df_ltl_routeheader_warn_volume] DEFAULT (0),
[lrh_warn_volume_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_warn_volume_uom] DEFAULT ('UNK'),
[lrh_effective_date] [datetime] NOT NULL CONSTRAINT [df_ltl_routeheader_eff_date] DEFAULT ('01/01/1950 00:00:00.000'),
[lrh_terminate_date] [datetime] NOT NULL CONSTRAINT [df_ltl_routeheader_term_date] DEFAULT ('12/31/2049 23:59:59.000'),
[lrh_createdate] [datetime] NULL,
[lrh_createuser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrh_max_count2] [decimal] (9, 2) NOT NULL CONSTRAINT [df_ltl_routeheader_max_count2] DEFAULT ((0)),
[lrh_max_count2_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_max_count2_uom] DEFAULT ('UNK'),
[lrh_warn_count2] [decimal] (9, 2) NOT NULL CONSTRAINT [df_ltl_routeheader_warn_count2] DEFAULT ((0)),
[lrh_warn_count2_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ltl_routeheader_warn_count2_uom] DEFAULT ('UNK')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_ltl_routeheader] ON [dbo].[ltl_routeheader]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 * 
 * NAME:
 * dbo.it_ltl_routeheader
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This insert trigger will save the create time and user to the record(s) being saved
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * N/A
 *
 * REVISION HISTORY:
 * 06/12/2006.01 ? PTS33344 - Jason Bauwin ? Original release
 *
 **/

  Begin
   declare @v_tmwuser varchar (255)
   exec gettmwuser @v_tmwuser output
    update ltl_routeheader
       set lrh_createdate = getdate(),
           lrh_createuser = @v_tmwuser
      from inserted
     where ltl_routeheader.lrh_id = inserted.lrh_id
  end
GO
ALTER TABLE [dbo].[ltl_routeheader] ADD CONSTRAINT [pk_ltl_routeheader_lrh_id] PRIMARY KEY CLUSTERED ([lrh_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_ltl_routeheader_lrh_name] ON [dbo].[ltl_routeheader] ([lrh_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltl_routeheader] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_routeheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltl_routeheader] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_routeheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_routeheader] TO [public]
GO
