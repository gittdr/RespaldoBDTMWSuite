CREATE TABLE [dbo].[TASK_QUESTIONS]
(
[TQ_ID] [int] NOT NULL IDENTITY(1, 1),
[TQ_QUESTION] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TQ_ANSWER] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TQ_ANSWER_ABBR] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TQ_LABELDEFINITION] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TQ_ANSWER_REQUIRED] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TQ_WHEN_TO_PROMPT] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_ID] [int] NULL,
[TTQ_ID] [int] NULL,
[TQ_CREATED_DATE] [datetime] NULL,
[TQ_CREATED_USER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TQ_MODIFIED_DATE] [datetime] NULL,
[TQ_MODIFIED_USER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TASK_QUESTIONS] ADD CONSTRAINT [PK_TASK_QUESTIONS] PRIMARY KEY CLUSTERED ([TQ_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_TASK_ID] ON [dbo].[TASK_QUESTIONS] ([TASK_ID]) INCLUDE ([TQ_ANSWER], [TQ_QUESTION]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TASK_QUESTIONS] TO [public]
GO
GRANT INSERT ON  [dbo].[TASK_QUESTIONS] TO [public]
GO
GRANT SELECT ON  [dbo].[TASK_QUESTIONS] TO [public]
GO
GRANT UPDATE ON  [dbo].[TASK_QUESTIONS] TO [public]
GO
