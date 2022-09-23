CREATE TABLE [dbo].[tblTemp151]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Row] [int] NOT NULL,
[Col] [int] NOT NULL,
[Type] [int] NULL,
[Caption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Len] [int] NULL,
[Mandatory] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tblTemp151_ITrig] ON [dbo].[tblTemp151] FOR INSERT AS
				/*
				 * PREVENT NULL VALUES IN 'Row'
				 */
				IF (SELECT Count(*) FROM inserted WHERE Row IS NULL) > 0
					BEGIN
						RAISERROR('Field ''Row'' cannot contain a null value.', 16,1)  -- PTS 64044
						ROLLBACK TRANSACTION
					END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tblTemp151_UTrig] ON [dbo].[tblTemp151] FOR UPDATE AS
				/*
				 * PREVENT NULL VALUES IN 'Row'
				 */
				IF (SELECT Count(*) FROM inserted WHERE Row IS NULL) > 0
					BEGIN
						RAISERROR('Field ''Row'' cannot contain a null value.', 16,1)  -- PTS 64044
						ROLLBACK TRANSACTION
					END
GO
ALTER TABLE [dbo].[tblTemp151] ADD CONSTRAINT [PK_tblTemp151_SN] PRIMARY KEY CLUSTERED ([SN], [Row], [Col]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblTemp151].[Row]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblTemp151].[Col]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblTemp151].[Type]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblTemp151].[Len]'
GO
GRANT DELETE ON  [dbo].[tblTemp151] TO [public]
GO
GRANT INSERT ON  [dbo].[tblTemp151] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblTemp151] TO [public]
GO
GRANT SELECT ON  [dbo].[tblTemp151] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblTemp151] TO [public]
GO
