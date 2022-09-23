SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[d_permit_dim_summary_sp] (@vl_lghnumber int) as

   declare @v_length float, @v_width float, @v_height float, @v_weight float

   exec permit_calculate_max_length_sp @vl_lghnumber, @v_length OUTPUT
   exec permit_calculate_max_width_sp  @vl_lghnumber, @v_width OUTPUT
   exec permit_calculate_max_height_sp @vl_lghnumber, @v_height OUTPUT
   exec permit_calculate_max_weight_sp @vl_lghnumber, @v_weight OUTPUT

   select @v_length, @v_width, @v_height, @v_weight

GO
GRANT EXECUTE ON  [dbo].[d_permit_dim_summary_sp] TO [public]
GO
