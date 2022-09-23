CREATE TABLE [dbo].[tariffrate_expired]
(
[tar_number] [int] NULL,
[trc_number_row] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_number_col] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_rate] [float] NULL,
[tra_retired] [datetime] NULL,
[active] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[row] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update] [datetime] NULL
) ON [PRIMARY]
GO
