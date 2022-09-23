CREATE TABLE [dbo].[WorkFlow_Schedule]
(
[WorkFlow_Schedule_ID] [int] NOT NULL IDENTITY(1, 1),
[WorkFlow_Template_id] [int] NOT NULL,
[SchUnit] [int] NOT NULL CONSTRAINT [DF__WorkFlow___SchUn__5F08EE09] DEFAULT ('1'),
[SchUnitType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__WorkFlow___SchUn__5FFD1242] DEFAULT ('Minute'),
[SchNextRun] [datetime] NULL CONSTRAINT [DF__WorkFlow___SchNe__60F1367B] DEFAULT ('1/1/1900'),
[SchStartTime] [datetime] NULL CONSTRAINT [DF__WorkFlow___SchSt__61E55AB4] DEFAULT ('12:00AM'),
[SchEndTime] [datetime] NULL CONSTRAINT [DF__WorkFlow___SchEn__62D97EED] DEFAULT ('11:59PM'),
[Sunday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Sunda__63CDA326] DEFAULT ('Y'),
[Monday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Monda__64C1C75F] DEFAULT ('Y'),
[Tuesday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Tuesd__65B5EB98] DEFAULT ('Y'),
[Wednesday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Wedne__66AA0FD1] DEFAULT ('Y'),
[Thursday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Thurs__679E340A] DEFAULT ('Y'),
[Friday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Frida__68925843] DEFAULT ('Y'),
[Saturday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Satur__69867C7C] DEFAULT ('Y'),
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WorkFlow___Activ__6A7AA0B5] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Schedule] ADD CONSTRAINT [FK__WorkFlow___WorkF__6B6EC4EE] FOREIGN KEY ([WorkFlow_Template_id]) REFERENCES [dbo].[WorkFlow_Template] ([Workflow_Template_ID])
GO
