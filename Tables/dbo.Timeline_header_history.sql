CREATE TABLE [dbo].[Timeline_header_history]
(
[tlh_hist_identity] [int] NOT NULL IDENTITY(1, 1),
[tlh_group_identity] [int] NOT NULL,
[tlh_number] [int] NOT NULL,
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
[tlh_SubrouteDomicile] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_DOW] [int] NULL,
[tlh_specialist] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tlh_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tlh_id_hist] ON [dbo].[Timeline_header_history] ([tlh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Timeline_header_history] TO [public]
GO
GRANT INSERT ON  [dbo].[Timeline_header_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Timeline_header_history] TO [public]
GO
GRANT SELECT ON  [dbo].[Timeline_header_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[Timeline_header_history] TO [public]
GO
