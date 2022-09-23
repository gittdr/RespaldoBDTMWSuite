CREATE TABLE [dbo].[StopTrailer]
(
[strl_id] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NOT NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[strl_bucket] [int] NULL,
[strl_dropped] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopTrailer] ADD CONSTRAINT [PK_StopTrailer] PRIMARY KEY CLUSTERED ([strl_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StopTrailer_stp_number] ON [dbo].[StopTrailer] ([stp_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopTrailer] ADD CONSTRAINT [FK_StopTrailer_Stops] FOREIGN KEY ([stp_number]) REFERENCES [dbo].[stops] ([stp_number]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StopTrailer] ADD CONSTRAINT [FK_StopTrailer_TrailerProfile] FOREIGN KEY ([trl_id]) REFERENCES [dbo].[trailerprofile] ([trl_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[StopTrailer] TO [public]
GO
GRANT INSERT ON  [dbo].[StopTrailer] TO [public]
GO
GRANT REFERENCES ON  [dbo].[StopTrailer] TO [public]
GO
GRANT SELECT ON  [dbo].[StopTrailer] TO [public]
GO
GRANT UPDATE ON  [dbo].[StopTrailer] TO [public]
GO
