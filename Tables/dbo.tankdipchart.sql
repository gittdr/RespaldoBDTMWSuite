CREATE TABLE [dbo].[tankdipchart]
(
[model_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tank_dip] [decimal] (12, 5) NOT NULL,
[tank_volume] [decimal] (12, 5) NOT NULL,
[tdc_id] [int] NOT NULL IDENTITY(1, 1),
[tdc_sequence] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[it_tankdipchart] on [dbo].[tankdipchart]
for insert
as
begin
    declare @updatecount int, @count int, @seq int
    declare @model_id varchar(12)
      
    select @updatecount = count(*) from inserted
    if @updatecount > 0
    begin
        select @model_id = max(model_id) from inserted
        select @count = 0
        select @count = max(tdc_sequence) from tankdipchart where model_id = @model_id
        if (select isnull(@count,0)) = 0
            select @seq = 1
        else
            select @seq = @count + 1
        end
	    update	tankdipchart
	       set	tdc_sequence = @seq
	      from	inserted
	     where	inserted.tdc_id = tankdipchart.tdc_id
end
GO
CREATE NONCLUSTERED INDEX [dk_tankdipchart_model_dip] ON [dbo].[tankdipchart] ([model_id], [tank_dip]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_tankdipchart_model_sequence] ON [dbo].[tankdipchart] ([model_id], [tdc_sequence]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_tankdipchart] ON [dbo].[tankdipchart] ([tdc_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tankdipchart] ADD CONSTRAINT [fk_tankdipchart_model] FOREIGN KEY ([model_id]) REFERENCES [dbo].[tankmodel] ([model_id])
GO
GRANT DELETE ON  [dbo].[tankdipchart] TO [public]
GO
GRANT INSERT ON  [dbo].[tankdipchart] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tankdipchart] TO [public]
GO
GRANT SELECT ON  [dbo].[tankdipchart] TO [public]
GO
GRANT UPDATE ON  [dbo].[tankdipchart] TO [public]
GO
