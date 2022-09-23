CREATE TABLE [dbo].[tankmodel]
(
[model_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[model_manufacture] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_capacity] [int] NULL,
[model_cap_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_dip_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_size_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_height] [smallint] NULL,
[model_width] [smallint] NULL,
[model_depth] [smallint] NULL,
[model_highdip] [smallint] NULL,
[model_lowdip] [smallint] NULL,
[model_warndip] [smallint] NULL,
[model_type1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_dip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tank_model_dip_type] DEFAULT ('L'),
[model_dip_scale_factor_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[model_active] [bit] NOT NULL CONSTRAINT [DF__tankmodel__model__461622CE] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tankmodel] ADD CONSTRAINT [pk_tankmodel] PRIMARY KEY CLUSTERED ([model_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tankmodel] TO [public]
GO
GRANT INSERT ON  [dbo].[tankmodel] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tankmodel] TO [public]
GO
GRANT SELECT ON  [dbo].[tankmodel] TO [public]
GO
GRANT UPDATE ON  [dbo].[tankmodel] TO [public]
GO
