///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF TRAFFIC GENERATOR BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
interface spdif_if ();
    logic iSPDIFin=0;
    logic iClk;
    logic CLK;
    logic [15:0] oDataL;
    logic [15:0] oDataR;
    logic oDatavalidL;
    logic oDatavalidR;
endinterface : spdif_if


