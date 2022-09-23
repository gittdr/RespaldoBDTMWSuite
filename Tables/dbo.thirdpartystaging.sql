CREATE TABLE [dbo].[thirdpartystaging]
(
[ss_id] [int] NOT NULL IDENTITY(1, 1),
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ss_updatedby] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[ss_updateddt] [datetime] NULL,
[ss_send_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_original_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_new_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[thirdpartystaging] ADD CONSTRAINT [pk_thirdpartystaging_ss_id] PRIMARY KEY CLUSTERED ([ss_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_thirdpartystaging_composite] ON [dbo].[thirdpartystaging] ([ord_number], [ss_updatedby], [lgh_number], [mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[thirdpartystaging] TO [public]
GO
GRANT INSERT ON  [dbo].[thirdpartystaging] TO [public]
GO
GRANT REFERENCES ON  [dbo].[thirdpartystaging] TO [public]
GO
GRANT SELECT ON  [dbo].[thirdpartystaging] TO [public]
GO
GRANT UPDATE ON  [dbo].[thirdpartystaging] TO [public]
GO
