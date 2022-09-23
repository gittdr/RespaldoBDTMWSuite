CREATE TABLE [dbo].[gl_dist_split]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[pick_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delv_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_precentage] [decimal] (10, 2) NULL,
[rowchgts] [timestamp] NOT NULL,
[pick_split] [decimal] (10, 2) NULL,
[delv_split] [decimal] (10, 2) NULL,
[hub1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub1_split] [decimal] (10, 2) NULL,
[hub2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub2_split] [decimal] (10, 2) NULL,
[hub3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub3_split] [decimal] (10, 2) NULL,
[hub4] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub4_split] [decimal] (10, 2) NULL,
[hub5] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub5_split] [decimal] (10, 2) NULL,
[hub6] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub6_split] [decimal] (10, 2) NULL,
[hub7] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub7_split] [decimal] (10, 2) NULL,
[hub8] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub8_split] [decimal] (10, 2) NULL,
[hub9] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub9_split] [decimal] (10, 2) NULL,
[hub10] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub10_split] [decimal] (10, 2) NULL,
[use_mileage] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pick_mileage_min] [decimal] (10, 2) NULL,
[delv_mileage_min] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gl_dist_split] ADD CONSTRAINT [PK__gl_dist___3213E83F42A1A537] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gl_dist_split] TO [public]
GO
GRANT INSERT ON  [dbo].[gl_dist_split] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gl_dist_split] TO [public]
GO
GRANT SELECT ON  [dbo].[gl_dist_split] TO [public]
GO
GRANT UPDATE ON  [dbo].[gl_dist_split] TO [public]
GO
