function transformador_gui_completo()

    % Crear la ventana principal
    f = figure('Name','Análisis de Transformador Completo', 'Position',[300 50 1000 700]);

    %% DATOS GENERALES DEL TRANSFORMADOR
    uicontrol(f,'Style','text','Position',[20 670 250 20],'String','Datos Generales del Transformador','FontWeight','bold');

    uicontrol(f,'Style','text','Position',[20 640 150 20],'String','Vp (V lado primario):');
    Vp_general = uicontrol(f,'Style','edit','Position',[180 640 100 25]);

    uicontrol(f,'Style','text','Position',[20 610 150 20],'String','Vs (V lado secundario):');
    Vs_general = uicontrol(f,'Style','edit','Position',[180 610 100 25]);

    %% CIRCUITO EQUIVALENTE
    uicontrol(f,'Style','text','Position',[20 580 250 20],'String','Circuito equivalente','FontWeight','bold');

    %% PRUEBA DE CORTOCIRCUITO
    uicontrol(f,'Style','text','Position',[20 550 250 20],'String','Prueba de Cortocircuito:','FontWeight','bold');

    uicontrol(f,'Style','text','Position',[20 520 150 20],'String','Vcc (V):');
    Vcc = uicontrol(f,'Style','edit','Position',[180 520 100 25]);

    uicontrol(f,'Style','text','Position',[20 490 150 20],'String','Icc (A):');
    Icc = uicontrol(f,'Style','edit','Position',[180 490 100 25]);

    uicontrol(f,'Style','text','Position',[20 460 150 20],'String','Pcc (W):');
    Pcc = uicontrol(f,'Style','edit','Position',[180 460 100 25]);

    uicontrol(f,'Style','pushbutton','Position',[300 490 200 30],...
              'String','Calcular Cortocircuito','Callback',@calcular_cortocircuito);

    %% PRUEBA EN VACÍO
    uicontrol(f,'Style','text','Position',[20 430 250 20],'String','Prueba en Vacío:','FontWeight','bold');

    uicontrol(f,'Style','text','Position',[20 400 150 20],'String','I0 (A):');
    I0 = uicontrol(f,'Style','edit','Position',[180 400 100 25]);

    uicontrol(f,'Style','text','Position',[20 370 150 20],'String','P0 (W):');
    P0 = uicontrol(f,'Style','edit','Position',[180 370 100 25]);
   
    uicontrol(f,'Style','text','Position',[57 340 150 20], ...
          'String','Nota: V0 ≈ Vs (en vacío)', 'ForegroundColor', [0 0.5 0]);

    uicontrol(f,'Style','pushbutton','Position',[300 400 200 30],...
              'String','Calcular Vacío','Callback',@calcular_vacio);

    %% REGULACIÓN DE TENSIÓN
    uicontrol(f,'Style','text','Position',[550 640 200 20],'String','Regulación de Tensión:','FontWeight','bold');

    uicontrol(f,'Style','text','Position',[500 610 150 20],'String','RS (Ω):');
    rs_input = uicontrol(f,'Style','edit','Position',[670 610 100 25],'String','0.2');

    uicontrol(f,'Style','text','Position',[500 580 150 20],'String','XS (Ω):');
    xs_input = uicontrol(f,'Style','edit','Position',[670 580 100 25],'String','0.4');

    uicontrol(f,'Style','text','Position',[500 550 150 20],'String','Voltaje nominal (V):');
    vnom_input = uicontrol(f,'Style','edit','Position',[670 550 100 25],'String','220');

    uicontrol(f,'Style','text','Position',[500 520 150 20],'String','Corriente base (A):');
    ibase_input = uicontrol(f,'Style','edit','Position',[670 520 100 25],'String','10');

    uicontrol(f,'Style','pushbutton','String','FP 0.65 (atraso)',...
        'Position',[540 460 180 30],'Callback',@(src,event)calcular_regulacion(0.65, false));

    uicontrol(f,'Style','pushbutton','String','FP 0.75 (adelanto)',...
        'Position',[540 420 180 30],'Callback',@(src,event)calcular_regulacion(0.75, true));

    uicontrol(f,'Style','checkbox', 'String','¿Adelanto?', 'Position',[540 380 150 20]);

    uicontrol(f,'Style','text','Position',[500 350 160 20],'String','FP personalizado:');
    fp_input = uicontrol(f,'Style','edit','Position',[670 350 100 25],'String','0.9');

    uicontrol(f,'Style','pushbutton','String','Calcular FP personalizado',...
        'Position',[540 310 180 30],'Callback',@calcular_fp_personalizado);

    uicontrol(f, 'Style', 'text', 'Position', [500 280 300 20], ...
        'String', '¡Advertencia! El FP no puede ser unitario ni >1.', 'ForegroundColor', 'red');

    %% RESULTADOS
    salida = uicontrol(f,'Style','text','Position',[20 20 920 200],...
        'HorizontalAlignment','left','Max', 10,'String','Resultados aparecerán aquí');

    %% FUNCIONES INTERNAS
    function calcular_cortocircuito(~,~)
        Vsc_ = str2double(get(Vcc,'String'));
        Isc_ = str2double(get(Icc,'String'));
        Psc_ = str2double(get(Pcc,'String'));
        Vp_  = str2double(get(Vp_general,'String'));
        Vs_  = str2double(get(Vs_general,'String'));  % Voltaje del secundario (este debería ser el nominal, pero se ajusta)

        if any(isnan([Vsc_, Isc_, Psc_, Vp_])) || Vsc_ == 0 || Isc_ == 0
            set(salida, 'String', 'Datos incompletos o inválidos en la prueba de cortocircuito.');
            return;
        end

        RP = Psc_ / Isc_^2;
        ZP = Vsc_ / Isc_;

        if RP > ZP
            set(salida, 'String', 'Error: RP > ZP. Verifica los datos ingresados.');
            return;
        end

        theta = acos(RP / ZP);
        XP = ZP * sin(theta);

        a = Vp_ / Vs_;
        RS = RP / a^2;
        XS = XP / a^2;
        ZS = ZP / a^2;

        texto = sprintf(['--- Resultados de Cortocircuito (referidos al lado ALTO) ---\n\n', ...
                         'RP = %.2f Ω\nZP = %.2f Ω\nθ = %.2f°\nXP = j%.2f Ω\n\n', ...
                         '--- Resultados referidos al lado BAJO ---\n\n', ...
                         'RS = %.2f Ω\nXS = j%.2f Ω\nZS = %.2f Ω'], ...
                         RP, ZP, rad2deg(theta), XP, RS, XS, ZS);

        set(salida, 'String', texto);
    end

    function calcular_vacio(~,~)
        Vs_ = str2double(get(Vs_general,'String'));
        I0_ = str2double(get(I0,'String'));
        P0_ = str2double(get(P0,'String'));
        Vp_ = str2double(get(Vp_general,'String'));

        if any(isnan([Vs_, I0_, P0_, Vp_])) || I0_ == 0 || Vs_ == 0
            set(salida, 'String', 'Datos incompletos o inválidos en la prueba en vacío.');
            return;
        end

        cos_theta = P0_ / (Vs_ * I0_);
        if cos_theta > 1 || cos_theta < -1
            set(salida, 'String', 'Error en el cálculo del ángulo: cos(θ) fuera de rango. Verifica los datos.');
            return;
        end

        theta = acos(cos_theta);
        Ip = I0_ * cos(theta);
        Im = I0_ * sin(theta);

        Rp2 = Vs_ / Ip;
        Xm2 = Vs_ / Im;

        a = Vp_ / Vs_;
        Rp1 = Rp2 * a^2;
        Xm1 = Xm2 * a^2;

        texto = sprintf(['--- Resultados de Prueba en Vacío (referidos al lado BAJO) ---\n\n', ...
                         'θ = %.2f°\nIp = %.2f A\nIm = %.2f A\nRp2 = %.2f Ω\nXm2 = %.2f Ω\n\n', ...
                         '--- Referidos al lado ALTO ---\n\n', ...
                         'Rp1 = %.2f Ω\nXm1 = %.2f Ω'], ...
                         rad2deg(theta), Ip, Im, Rp2, Xm2, Rp1, Xm1);

        set(salida, 'String', texto);
    end

    function calcular_regulacion(fp, es_adelanto)
        RS = str2double(get(rs_input, 'String'));
        XS = str2double(get(xs_input, 'String'));
        V_nom = str2double(get(vnom_input, 'String'));
        I_base = str2double(get(ibase_input, 'String'));

        if any(isnan([RS, XS, V_nom, I_base]))
            set(salida, 'String', 'Datos inválidos para el cálculo de regulación.');
            return;
        end

        theta = acos(fp);
        if es_adelanto
            theta = -theta;
        end

        cargas = [0.4 0.6 0.8 1.0 1.2];
        texto = sprintf('--- Regulación de Tensión ---\nFP = %.2f (%s)\n\n', fp, ...
                        ternary(es_adelanto,'adelanto','atraso'));

        for i = 1:length(cargas)
            I = I_base * cargas(i);
            deltaV = I * (RS * cos(theta) + XS * sin(theta));
            regulacion = (deltaV / V_nom) * 100;
            texto = [texto, sprintf('Carga %.0f%%: %.2f %%\n', cargas(i)*100, regulacion)];
        end

        set(salida,'String',texto);
    end

    function calcular_fp_personalizado(~,~)
        fp = str2double(get(fp_input, 'String'));
        if fp >= 1
            set(salida, 'String', 'Error: El FP no puede ser unitario ni mayor que 1.');
            return;
        end
        es_adelanto = get(findobj(f,'Style','checkbox'),'Value');

        calcular_regulacion(fp, es_adelanto);
    end

    function r = ternary(cond, val_true, val_false)
        if cond
            r = val_true;
        else
            r = val_false;
        end
    end

end













