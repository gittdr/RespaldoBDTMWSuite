CREATE TABLE [dbo].[drivertimecustom]
(
[dtc_id] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtc_date] [datetime] NULL,
[dtc_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtc_hours] [decimal] (13, 4) NULL,
[dtc_manual_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtc_created_date] [datetime] NOT NULL,
[dtc_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dtc_modified_date] [datetime] NOT NULL,
[dtc_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[drivertimecustom] ADD CONSTRAINT [PK_drivertimecustom] PRIMARY KEY NONCLUSTERED ([dtc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_drivertimecustom_cmp_id] ON [dbo].[drivertimecustom] ([cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_drivertimecustom_dtc_date] ON [dbo].[drivertimecustom] ([dtc_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_drivertimecustom_mpp_id] ON [dbo].[drivertimecustom] ([mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivertimecustom] TO [public]
GO
GRANT INSERT ON  [dbo].[drivertimecustom] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivertimecustom] TO [public]
GO
GRANT SELECT ON  [dbo].[drivertimecustom] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivertimecustom] TO [public]
GO
