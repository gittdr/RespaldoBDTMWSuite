CREATE TABLE [dbo].[checkmirrow]
(
[ckh_Date] [datetime] NULL,
[ckh_comment] [char] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckh_tractor] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckh_lonseconds] [int] NULL,
[ckh_latseconds] [int] NULL,
[chk_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
