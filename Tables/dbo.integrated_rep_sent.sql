CREATE TABLE [dbo].[integrated_rep_sent]
(
[irs_id] [int] NOT NULL IDENTITY(1, 1),
[irs_driverid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_tractorid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_carrierid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_other] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_body] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_from] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irs_created_date] [datetime] NOT NULL,
[irs_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irs_modified_date] [datetime] NOT NULL,
[irs_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_rep_sent] ADD CONSTRAINT [PK_integrated_rep_sent] PRIMARY KEY NONCLUSTERED ([irs_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integrated_rep_sent] TO [public]
GO
GRANT INSERT ON  [dbo].[integrated_rep_sent] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integrated_rep_sent] TO [public]
GO
GRANT SELECT ON  [dbo].[integrated_rep_sent] TO [public]
GO
GRANT UPDATE ON  [dbo].[integrated_rep_sent] TO [public]
GO
