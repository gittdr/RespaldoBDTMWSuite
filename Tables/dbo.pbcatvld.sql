CREATE TABLE [dbo].[pbcatvld]
(
[pbv_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbv_vald] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbv_type] [smallint] NOT NULL,
[pbv_cntr] [int] NULL,
[pbv_msg] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pbcatvld_idx] ON [dbo].[pbcatvld] ([pbv_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcatvld] TO [public]
GO
GRANT INSERT ON  [dbo].[pbcatvld] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pbcatvld] TO [public]
GO
GRANT SELECT ON  [dbo].[pbcatvld] TO [public]
GO
GRANT UPDATE ON  [dbo].[pbcatvld] TO [public]
GO
