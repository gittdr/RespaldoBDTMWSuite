CREATE TABLE [dbo].[Timeline_detail_history]
(
[tld_hist_identity] [int] NOT NULL IDENTITY(1, 1),
[tld_group_identity] [int] NOT NULL,
[tld_number] [int] NOT NULL,
[tlh_number] [int] NOT NULL,
[tld_sequence] [int] NULL,
[tld_master_ordnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tld_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tld_origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tld_arrive_orig] [datetime] NULL,
[tld_arrive_orig_lead] [int] NULL,
[tld_depart_orig] [datetime] NULL,
[tld_depart_orig_lead] [int] NULL,
[tld_dest] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tld_arrive_yard] [datetime] NULL,
[tld_arrive_lead] [int] NULL,
[tld_arrive_dest] [datetime] NULL,
[tld_arrive_dest_lead] [int] NULL,
[tld_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tld_updatedon] [datetime] NULL,
[tld_saturday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tld_sunday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tld_id_hist] ON [dbo].[Timeline_detail_history] ([tld_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tld_tlh_id_hist] ON [dbo].[Timeline_detail_history] ([tlh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Timeline_detail_history] TO [public]
GO
GRANT INSERT ON  [dbo].[Timeline_detail_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Timeline_detail_history] TO [public]
GO
GRANT SELECT ON  [dbo].[Timeline_detail_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[Timeline_detail_history] TO [public]
GO
