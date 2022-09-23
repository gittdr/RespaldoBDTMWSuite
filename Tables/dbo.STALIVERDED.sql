CREATE TABLE [dbo].[STALIVERDED]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[fecha] [datetime] NULL CONSTRAINT [DF__STALIVERD__fecha__4B2CDDE5] DEFAULT (getdate())
) ON [PRIMARY]
GO
