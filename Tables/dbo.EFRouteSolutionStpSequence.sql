CREATE TABLE [dbo].[EFRouteSolutionStpSequence]
(
[ss_id] [int] NOT NULL IDENTITY(1, 1),
[requestid] [int] NOT NULL,
[ss_stoptype] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_sequence] [int] NULL,
[ss_fuelid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_locnam] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_zip] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_highway] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_latitude] [int] NULL,
[ss_longitude] [int] NULL,
[ss_highwayexit] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EFRouteSolutionStpSequence] ADD CONSTRAINT [pk_efrsss] PRIMARY KEY CLUSTERED ([ss_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_requestid] ON [dbo].[EFRouteSolutionStpSequence] ([requestid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EFRouteSolutionStpSequence] TO [public]
GO
GRANT INSERT ON  [dbo].[EFRouteSolutionStpSequence] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EFRouteSolutionStpSequence] TO [public]
GO
GRANT SELECT ON  [dbo].[EFRouteSolutionStpSequence] TO [public]
GO
GRANT UPDATE ON  [dbo].[EFRouteSolutionStpSequence] TO [public]
GO
