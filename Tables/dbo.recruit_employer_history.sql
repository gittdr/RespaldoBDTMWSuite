CREATE TABLE [dbo].[recruit_employer_history]
(
[reh_id] [int] NOT NULL IDENTITY(1, 1),
[rec_id] [int] NOT NULL,
[reh_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_addr1] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_addr2] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_city] [int] NULL,
[reh_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_faxphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_email] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_contact] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_web] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reh_start_date] [datetime] NULL,
[reh_end_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[recruit_employer_history] ADD CONSTRAINT [PK__recruit_employer__346D4365] PRIMARY KEY CLUSTERED ([reh_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [reh_rec_id] ON [dbo].[recruit_employer_history] ([rec_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[recruit_employer_history] TO [public]
GO
GRANT INSERT ON  [dbo].[recruit_employer_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[recruit_employer_history] TO [public]
GO
GRANT SELECT ON  [dbo].[recruit_employer_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[recruit_employer_history] TO [public]
GO
