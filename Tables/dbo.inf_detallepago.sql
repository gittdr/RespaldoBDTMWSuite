CREATE TABLE [dbo].[inf_detallepago]
(
[consec] [int] NOT NULL,
[leg] [int] NOT NULL,
[mov] [int] NOT NULL,
[ord] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inf_detallepago] ADD CONSTRAINT [pk_detapago] PRIMARY KEY NONCLUSTERED ([consec]) ON [PRIMARY]
GO
