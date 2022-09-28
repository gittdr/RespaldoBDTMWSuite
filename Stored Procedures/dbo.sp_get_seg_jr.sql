SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_get_seg_jr](                                     
@leg varchar(100)
)
as
begin
   SELECT TOP 1 billto, estatus FROM segmentosportimbrar_JR WHERE segmento = @leg
end
GO
