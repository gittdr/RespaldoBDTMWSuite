SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- create view of edi_orderstate_transition that includes the descriptions
CREATE VIEW [dbo].[edi_orderstate_transition_view] 
    AS
    SELECT evs_code, 
           (SELECT esc_description
              FROM edi_orderstate 
             WHERE edi_orderstate.esc_code = edi_orderstate_transition.evs_code) evs_codedescription, 
           evs_validnextcode, 
           (SELECT esc_description
              FROM edi_orderstate 
             WHERE edi_orderstate.esc_code = edi_orderstate_transition.evs_validnextcode) evs_validnextcodedescription 
      FROM edi_orderstate_transition
GO
GRANT SELECT ON  [dbo].[edi_orderstate_transition_view] TO [public]
GO
