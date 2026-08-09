-- =============================================================================
-- CONFIGURAÇÃO DO REPOSITÓRIO GITHUB
-- =============================================================================
local GITHUB_USER = "Shrimpo-DW"
local GITHUB_REPO = "SigmaGalleryv2Files"

-- Tabelas que serão preenchidas automaticamente pela API do GitHub
local listaDeImagensNormais = {}
local listaDeImagensSecretas = {}
local listaDeImagensPremium = {} 
local listaDeImagens = {} 

-- =============================================================================
-- COMPATIBILIDADE UNIVERSAL DE EXECUTORES
-- =============================================================================
local HttpService = game:GetService("HttpService")
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local getcustomasset = getcustomasset or getsynasset

local enviaRequisicao = request or http_request or (http and http.request) or syn.request
if not enviaRequisicao then
    error("Seu executor não possui suporte a requisições HTTP (request)!")
end

if not isfolder("Misc") then
    makefolder("Misc")
end

-- =============================================================================
-- CONFIGURAÇÕES DO SISTEMA DE KEY E ESTADOS
-- =============================================================================
local KeySecretas = "ShrimpoTop1"    -- Apenas para as Secretas
local KeyTudo = "BarneysCoffe"       -- Para liberar Tudo de uma vez
local KeyDesbloqueada = false
local TipoKeyAtivada = ""            -- Guarda "Secrets" ou "All"
local ModoSecretoAtivo = false
local SequenciaBotoes = ""
local KeySistemaAtivo = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("SigmaGallery2.1") then
    PlayerGui["SigmaGallery2.1"]:Destroy()
end

local indiceAtual = 1
local escalaZoom = 1.0
local maxZoom = 4.0

-- DETECÇÃO E FATOR DE ESCALA PARA MOBILE (0.5x menor se for touch)
local IsMobile = UserInputService.TouchEnabled
local ScaleMultiplier = IsMobile and 0.5 or 1.0

-- =============================================================================
-- PALETA DE CORES MASTER & FONTES UNIVERSAIS
-- =============================================================================
local CorFundo = Color3.fromRGB(11, 9, 9)
local CorTopo = Color3.fromRGB(18, 14, 14)
local CorContorno = Color3.fromRGB(36, 26, 26)
local CorDestaque = Color3.fromRGB(255, 51, 51) 
local CorBotao = Color3.fromRGB(24, 18, 18)
local CorTexto = Color3.fromRGB(255, 255, 255)
local CorTextoMuted = Color3.fromRGB(140, 115, 115)
local FontePadrao = Enum.Font.SourceSansBold
local FonteTexto = Enum.Font.SourceSans

-- =============================================================================
-- INTERFACE PRINCIPAL
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SigmaGallery2.1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460 * ScaleMultiplier, 0, 620 * ScaleMultiplier) 
MainFrame.Position = UDim2.new(0.5, -(230 * ScaleMultiplier), 0.5, -(310 * ScaleMultiplier))
MainFrame.BackgroundColor3 = CorFundo
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16 * ScaleMultiplier)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CorContorno
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- TOPO (BARRA DE TITULO PREMIUM)
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 60 * ScaleMultiplier) 
Topbar.BackgroundColor3 = CorTopo
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner", Topbar)
TopbarCorner.CornerRadius = UDim.new(0, 16 * ScaleMultiplier)

local TopbarHide = Instance.new("Frame")
TopbarHide.Size = UDim2.new(1, 0, 0, 15 * ScaleMultiplier)
TopbarHide.Position = UDim2.new(0, 0, 1, -(15 * ScaleMultiplier))
TopbarHide.BackgroundColor3 = CorTopo
TopbarHide.BorderSizePixel = 0
TopbarHide.ZIndex = 0
TopbarHide.Parent = Topbar

local TopbarLine = Instance.new("Frame")
TopbarLine.Size = UDim2.new(1, 0, 0, 1)
TopbarLine.Position = UDim2.new(0, 0, 1, 0)
TopbarLine.BackgroundColor3 = CorContorno
TopbarLine.BorderSizePixel = 0
TopbarLine.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -(180 * ScaleMultiplier), 1, 0) 
Title.Position = UDim2.new(0, 24 * ScaleMultiplier, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SIGMA GALLERY V2.1"
Title.TextColor3 = CorTexto
Title.Font = FontePadrao
Title.TextSize = math.max(9, 16 * ScaleMultiplier)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local function AplicarEfeitosBotaoPremium(btn, stroke, corOriginal, corHover, corStrokeOriginal, corStrokeHover)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = corHover}):Play()
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = corStrokeHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = corOriginal}):Play()
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = corStrokeOriginal}):Play()
        end
    end)
end

-- BOTÃO ALTERNAR MODO
local SwitchBtn = Instance.new("TextButton")
SwitchBtn.Size = UDim2.new(0, 90 * ScaleMultiplier, 0, 30 * ScaleMultiplier)
SwitchBtn.Position = UDim2.new(1, -(190 * ScaleMultiplier), 0.5, -(15 * ScaleMultiplier))
SwitchBtn.BackgroundColor3 = CorBotao
SwitchBtn.Text = "Normals"
SwitchBtn.TextColor3 = CorTexto
SwitchBtn.Font = FontePadrao
SwitchBtn.TextSize = math.max(8, 13 * ScaleMultiplier)
SwitchBtn.Visible = false
SwitchBtn.Parent = Topbar
Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0, 6 * ScaleMultiplier)
local SwitchStroke = Instance.new("UIStroke", SwitchBtn)
SwitchStroke.Color = CorContorno
SwitchStroke.Thickness = 1
AplicarEfeitosBotaoPremium(SwitchBtn, SwitchStroke, CorBotao, CorDestaque, CorContorno, CorDestaque)

-- BOTÃO MINIMIZAR
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30 * ScaleMultiplier, 0, 30 * ScaleMultiplier) 
MinBtn.Position = UDim2.new(1, -(85 * ScaleMultiplier), 0.5, -(15 * ScaleMultiplier))
MinBtn.BackgroundColor3 = CorBotao
MinBtn.Text = "−"
MinBtn.TextColor3 = CorTextoMuted
MinBtn.Font = FontePadrao
MinBtn.TextSize = math.max(12, 20 * ScaleMultiplier)
MinBtn.Parent = Topbar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6 * ScaleMultiplier)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = CorContorno
MinStroke.Thickness = 1
AplicarEfeitosBotaoPremium(MinBtn, MinStroke, CorBotao, Color3.fromRGB(35, 25, 25), CorContorno, Color3.fromRGB(60, 40, 40))

-- BOTÃO FECHAR
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30 * ScaleMultiplier, 0, 30 * ScaleMultiplier) 
CloseBtn.Position = UDim2.new(1, -(45 * ScaleMultiplier), 0.5, -(15 * ScaleMultiplier))
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
CloseBtn.Text = "X" 
CloseBtn.TextColor3 = CorDestaque
CloseBtn.Font = FontePadrao
CloseBtn.TextSize = math.max(9, 14 * ScaleMultiplier)
CloseBtn.Parent = Topbar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6 * ScaleMultiplier)
local CloseStroke = Instance.new("UIStroke", CloseBtn)
CloseStroke.Color = Color3.fromRGB(70, 25, 25)
CloseStroke.Thickness = 1
AplicarEfeitosBotaoPremium(CloseBtn, CloseStroke, Color3.fromRGB(30, 15, 15), CorDestaque, Color3.fromRGB(70, 25, 25), CorTexto)

-- CONTEINER DA IMAGEM
local ImageFrame = Instance.new("Frame")
ImageFrame.Size = UDim2.new(1, -(40 * ScaleMultiplier), 0, 400 * ScaleMultiplier) 
ImageFrame.Position = UDim2.new(0, 20 * ScaleMultiplier, 0, 80 * ScaleMultiplier) 
ImageFrame.BackgroundColor3 = Color3.fromRGB(7, 5, 5)
ImageFrame.BorderSizePixel = 0
ImageFrame.ClipsDescendants = true
ImageFrame.Parent = MainFrame

Instance.new("UICorner", ImageFrame).CornerRadius = UDim.new(0, 12 * ScaleMultiplier)
local ImageFrameStroke = Instance.new("UIStroke", ImageFrame)
ImageFrameStroke.Color = CorContorno
ImageFrameStroke.Thickness = 1

local ExibicaoImagem = Instance.new("ImageLabel")
ExibicaoImagem.Size = UDim2.new(1, -(16 * ScaleMultiplier), 1, -(16 * ScaleMultiplier))
ExibicaoImagem.Position = UDim2.new(0.5, 0, 0.5, 0)
ExibicaoImagem.AnchorPoint = Vector2.new(0.5, 0.5)
ExibicaoImagem.BackgroundTransparency = 1
ExibicaoImagem.ScaleType = Enum.ScaleType.Fit
ExibicaoImagem.Active = true
ExibicaoImagem.Parent = ImageFrame

-- INDICADOR DE NOME
local NomeTexto = Instance.new("TextLabel")
NomeTexto.Size = UDim2.new(1, -(40 * ScaleMultiplier), 0, 20 * ScaleMultiplier)
NomeTexto.Position = UDim2.new(0, 20 * ScaleMultiplier, 0, 495 * ScaleMultiplier) 
NomeTexto.BackgroundTransparency = 1
NomeTexto.TextColor3 = CorTextoMuted
NomeTexto.Font = FonteTexto
NomeTexto.TextSize = math.max(10, 15 * ScaleMultiplier)
NomeTexto.TextWrapped = true
NomeTexto.Parent = MainFrame

local function criarBotaoNavegacao(texto, pos, tamanhoGrande)
    local btn = Instance.new("TextButton")
    btn.Size = tamanhoGrande and UDim2.new(0, 90 * ScaleMultiplier, 0, 40 * ScaleMultiplier) or UDim2.new(0, 75 * ScaleMultiplier, 0, 40 * ScaleMultiplier)
    btn.Position = pos
    btn.BackgroundColor3 = CorBotao
    btn.Text = texto
    btn.TextColor3 = CorTexto
    btn.Font = FontePadrao
    btn.TextSize = tamanhoGrande and math.max(8, 13 * ScaleMultiplier) or math.max(12, 20 * ScaleMultiplier)
    btn.Parent = MainFrame

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8 * ScaleMultiplier)
    local s = Instance.new("UIStroke", btn)
    s.Color = CorContorno
    s.Thickness = 1

    AplicarEfeitosBotaoPremium(btn, s, CorBotao, CorDestaque, CorContorno, CorDestaque)
    return btn
end

local BtnAnterior = criarBotaoNavegacao("«", UDim2.new(0, 20 * ScaleMultiplier, 1, -(65 * ScaleMultiplier)), false)
local BtnZoomMenos = criarBotaoNavegacao("−", UDim2.new(0, 105 * ScaleMultiplier, 1, -(65 * ScaleMultiplier)), false)
local BtnZoomMais = criarBotaoNavegacao("+", UDim2.new(1, -(180 * ScaleMultiplier), 1, -(65 * ScaleMultiplier)), false)
local BtnProximo = criarBotaoNavegacao("»", UDim2.new(1, -(95 * ScaleMultiplier), 1, -(65 * ScaleMultiplier)), false)

-- KEY FRAME
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(1, 0, 1, -(60 * ScaleMultiplier))
KeyFrame.Position = UDim2.new(0, 0, 0, 60 * ScaleMultiplier)
KeyFrame.BackgroundColor3 = CorFundo
KeyFrame.BorderSizePixel = 0
KeyFrame.Visible = false
KeyFrame.Parent = MainFrame

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, -(40 * ScaleMultiplier), 0, 30 * ScaleMultiplier)
KeyLabel.Position = UDim2.new(0, 20 * ScaleMultiplier, 0, 110 * ScaleMultiplier)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Access Key Required"
KeyLabel.TextColor3 = CorTexto
KeyLabel.Font = FontePadrao
KeyLabel.TextSize = math.max(10, 15 * ScaleMultiplier)
KeyLabel.Parent = KeyFrame

local KeyTextBox = Instance.new("TextBox")
KeyTextBox.Size = UDim2.new(0, 300 * ScaleMultiplier, 0, 44 * ScaleMultiplier)
KeyTextBox.Position = UDim2.new(0.5, -(150 * ScaleMultiplier), 0, 165 * ScaleMultiplier)
KeyTextBox.BackgroundColor3 = Color3.fromRGB(16, 12, 12)
KeyTextBox.Text = ""
KeyTextBox.PlaceholderText = "Insert Validation Token"
KeyTextBox.PlaceholderColor3 = Color3.fromRGB(90, 70, 70)
KeyTextBox.TextColor3 = CorTexto
KeyTextBox.Font = FonteTexto
KeyTextBox.TextSize = math.max(10, 15 * ScaleMultiplier)
KeyTextBox.Parent = KeyFrame
Instance.new("UICorner", KeyTextBox).CornerRadius = UDim.new(0, 8 * ScaleMultiplier)
local BoxStroke = Instance.new("UIStroke", KeyTextBox)
BoxStroke.Color = CorContorno
BoxStroke.Thickness = 1

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0, 145 * ScaleMultiplier, 0, 40 * ScaleMultiplier)
CheckBtn.Position = UDim2.new(0.5, -(150 * ScaleMultiplier), 0, 230 * ScaleMultiplier)
CheckBtn.BackgroundColor3 = CorDestaque
CheckBtn.Text = "Verify"
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
CheckBtn.Font = FontePadrao
CheckBtn.TextSize = math.max(8, 13 * ScaleMultiplier)
CheckBtn.Parent = KeyFrame
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 8 * ScaleMultiplier)
local CheckStroke = Instance.new("UIStroke", CheckBtn)
CheckStroke.Color = CorDestaque
AplicarEfeitosBotaoPremium(CheckBtn, CheckStroke, CorDestaque, Color3.fromRGB(255, 80, 80), CorDestaque, CorTexto)

local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0, 145 * ScaleMultiplier, 0, 40 * ScaleMultiplier)
BackBtn.Position = UDim2.new(0.5, 5 * ScaleMultiplier, 0, 230 * ScaleMultiplier)
BackBtn.BackgroundColor3 = CorBotao 
BackBtn.Text = "Return"
BackBtn.TextColor3 = CorTextoMuted 
BackBtn.Font = FontePadrao
BackBtn.TextSize = math.max(8, 13 * ScaleMultiplier)
BackBtn.Parent = KeyFrame
Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0, 8 * ScaleMultiplier)
local BackStroke = Instance.new("UIStroke", BackBtn)
BackStroke.Color = CorContorno
AplicarEfeitosBotaoPremium(BackBtn, BackStroke, CorBotao, Color3.fromRGB(35, 25, 25), CorContorno, Color3.fromRGB(60, 40, 40))

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 140 * ScaleMultiplier, 0, 40 * ScaleMultiplier) 
OpenButton.Position = UDim2.new(0, 24 * ScaleMultiplier, 1, -(64 * ScaleMultiplier))
OpenButton.BackgroundColor3 = CorTopo
OpenButton.Text = "Open"
OpenButton.TextColor3 = CorTexto
OpenButton.Font = FontePadrao
OpenButton.TextSize = math.max(8, 12 * ScaleMultiplier)
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 10 * ScaleMultiplier)
local OpenStroke = Instance.new("UIStroke", OpenButton)
OpenStroke.Color = CorContorno
OpenStroke.Thickness = 1.2
AplicarEfeitosBotaoPremium(OpenButton, OpenStroke, CorTopo, CorDestaque, CorContorno, CorDestaque)

-- =============================================================================
-- LOGICA DO MOTOR DA INTERFACE & LUA ENGINE GITHUB (RAIZ)
-- =============================================================================
local function ajustarLimitesPosicao()
    local containerW = ImageFrame.AbsoluteSize.X
    local containerH = ImageFrame.AbsoluteSize.Y
    local imgW = (containerW - (16 * ScaleMultiplier)) * escalaZoom
    local imgH = (containerH - (16 * ScaleMultiplier)) * escalaZoom
    local limiteX = math.max(0, (imgW - containerW) / 2 + (8 * ScaleMultiplier))
    local limiteY = math.max(0, (imgH - containerH) / 2 + (8 * ScaleMultiplier))
    local atualX = ExibicaoImagem.Position.X.Offset
    local atualY = ExibicaoImagem.Position.Y.Offset
    local novoX = math.clamp(atualX, -limiteX, limiteX)
    local novoY = math.clamp(atualY, -limiteY, limiteY)
    ExibicaoImagem.Position = UDim2.new(0.5, novoX, 0.5, novoY)
end

local function atualizarZoom(novoZoom)
    escalaZoom = math.clamp(novoZoom, 1.0, maxZoom)
    ExibicaoImagem.Size = UDim2.new(escalaZoom, -(16 * ScaleMultiplier) * escalaZoom, escalaZoom, -(16 * ScaleMultiplier) * escalaZoom)
    if escalaZoom == 1.0 then
        ExibicaoImagem.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        ajustarLimitesPosicao()
    end
end

local function resetarZoom()
    atualizarZoom(1.0)
end

local function atualizarGaleria()
    resetarZoom()
    local item = listaDeImagens[indiceAtual]

    if item then
        local caminhoLocal = "Misc/" .. item.nome

        if isfile(caminhoLocal) then
            local assetSucesso, assetId = pcall(function()
                return getcustomasset(caminhoLocal)
            end)
            if assetSucesso then
                ExibicaoImagem.Image = assetId
                NomeTexto.Text = string.upper(item.nome) .. " — [" .. indiceAtual .. " / " .. #listaDeImagens .. "]"
            else
                ExibicaoImagem.Image = ""
                NomeTexto.Text = "ERROR RENDERING: " .. string.upper(item.nome)
            end
        else
            ExibicaoImagem.Image = ""
            NomeTexto.Text = "DOWNLOADING FILE... " .. string.upper(item.nome)
        end
    else
        ExibicaoImagem.Image = ""
        NomeTexto.Text = "NO FILES INSTALLED YET"
    end
end

local function escanearEReceberImagensDoGithub()
    local urlAPI = string.format("https://api.github.com/repos/%s/%s/contents/", GITHUB_USER, GITHUB_REPO)
    
    local sucesso, resposta = pcall(function()
        return enviaRequisicao({
            Url = urlAPI,
            Method = "GET",
            Headers = { ["User-Agent"] = "RobloxStudio/1.0" }
        })
    end)
    
    if sucesso and resposta.StatusCode == 200 then
        local arquivos = HttpService:JSONDecode(resposta.Body)
        
        listaDeImagensNormais = {}
        listaDeImagensSecretas = {}
        listaDeImagensPremium = {}

        for _, arquivo in ipairs(arquivos) do
            if arquivo.type == "file" then
                local dadosImagem = {
                    nome = arquivo.name,
                    url = arquivo.download_url
                }
                
                local nomeMinusculo = string.lower(arquivo.name)
                
                if string.sub(nomeMinusculo, 1, 3) == "pre" and string.find(nomeMinusculo, "mium", 4, true) then
                    table.insert(listaDeImagensPremium, dadosImagem)
                elseif string.sub(nomeMinusculo, 1, 3) == "sec" then
                    table.insert(listaDeImagensSecretas, dadosImagem)
                else
                    table.insert(listaDeImagensNormais, dadosImagem)
                end
            end
        end
        
        -- Atualização dinâmica baseada no tipo de chave logada
        if KeyDesbloqueada then
            if TipoKeyAtivada == "All" then
                listaDeImagens = {}
                for _, v in ipairs(listaDeImagensNormais) do table.insert(listaDeImagens, v) end
                for _, v in ipairs(listaDeImagensSecretas) do table.insert(listaDeImagens, v) end
                for _, v in ipairs(listaDeImagensPremium) do table.insert(listaDeImagens, v) end
            elseif TipoKeyAtivada == "Secrets" then
                listaDeImagens = listaDeImagensSecretas
            end
        else
            listaDeImagens = listaDeImagensNormais
        end
        
        atualizarGaleria()

        local todasImagens = {}
        for _, v in ipairs(listaDeImagensNormais) do table.insert(todasImagens, v) end
        for _, v in ipairs(listaDeImagensSecretas) do table.insert(todasImagens, v) end
        for _, v in ipairs(listaDeImagensPremium) do table.insert(todasImagens, v) end

        for _, img in ipairs(todasImagens) do
            local caminhoLocal = "Misc/" .. img.nome
            if not isfile(caminhoLocal) then
                task.spawn(function()
                    local dSucesso, dResposta = pcall(function()
                        return enviaRequisicao({
                            Url = img.url,
                            Method = "GET",
                            Headers = { ["User-Agent"] = "RobloxStudio/1.0" }
                        })
                    end)
                    
                    if dSucesso and dResposta.StatusCode == 200 then
                        writefile(caminhoLocal, dResposta.Body)
                        if listaDeImagens[indiceAtual] and listaDeImagens[indiceAtual].nome == img.nome then
                            atualizarGaleria()
                        end
                    end
                end)
            else
                if listaDeImagens[indiceAtual] and listaDeImagens[indiceAtual].nome == img.nome then
                    atualizarGaleria()
                end
            end
        end
    else
        NomeTexto.Text = "CONNECTION ERROR WITH GITHUB API"
    end
end

local function iniciarProcesso()
    NomeTexto.Text = "CONNECTING TO GITHUB FILES..."
    escanearEReceberImagensDoGithub()
end

local function setGaleriaVisibilidade(visivel)
    ImageFrame.Visible = visivel
    NomeTexto.Visible = visivel
    BtnAnterior.Visible = visivel
    BtnZoomMenos.Visible = visivel
    BtnZoomMais.Visible = visivel
    BtnProximo.Visible = visivel
end

local function RegistrarBotao(char)
    if not KeySistemaAtivo then return end
    if UserInputService:GetFocusedTextBox() then return end

    SequenciaBotoes = SequenciaBotoes .. char
    if string.sub("+>>-<>>+", 1, string.len(SequenciaBotoes)) ~= SequenciaBotoes then
        SequenciaBotoes = char 
    end

    if SequenciaBotoes == "+>>-<>>+" then
        SequenciaBotoes = ""
        setGaleriaVisibilidade(false)
        KeyTextBox.Text = ""
        KeyFrame.Visible = true
    end
end

-- CONTROLES
BtnAnterior.MouseButton1Click:Connect(function()
    RegistrarBotao("<")
    if #listaDeImagens == 0 then return end
    indiceAtual = (indiceAtual - 2 + #listaDeImagens) % #listaDeImagens + 1
    atualizarGaleria()
end)

BtnProximo.MouseButton1Click:Connect(function()
    RegistrarBotao(">")
    if #listaDeImagens == 0 then return end
    indiceAtual = indiceAtual % #listaDeImagens + 1
    atualizarGaleria()
end)

BtnZoomMais.MouseButton1Click:Connect(function()
    RegistrarBotao("+")
    atualizarZoom(escalaZoom + 0.4)
end)

BtnZoomMenos.MouseButton1Click:Connect(function()
    RegistrarBotao("-")
    atualizarZoom(escalaZoom - 0.4)
end)

-- VERIFICAÇÃO DAS KEYS
CheckBtn.MouseButton1Click:Connect(function()
    local input = KeyTextBox.Text
    if input == KeyTudo or input == KeySecretas then
        KeyDesbloqueada = true
        KeySistemaAtivo = false 
        KeyFrame.Visible = false
        indiceAtual = 1
        ModoSecretoAtivo = true

        if input == KeyTudo then
            TipoKeyAtivada = "All"
            listaDeImagens = {}
            for _, v in ipairs(listaDeImagensNormais) do table.insert(listaDeImagens, v) end
            for _, v in ipairs(listaDeImagensSecretas) do table.insert(listaDeImagens, v) end
            for _, v in ipairs(listaDeImagensPremium) do table.insert(listaDeImagens, v) end
            SwitchBtn.Text = "All Unlocked"
        else
            TipoKeyAtivada = "Secrets"
            listaDeImagens = listaDeImagensSecretas
            SwitchBtn.Text = "Secrets"
        end

        SwitchBtn.Visible = true
        setGaleriaVisibilidade(true)
        atualizarGaleria()
    else
        KeyTextBox.Text = ""
        KeyTextBox.PlaceholderText = "Invalid Token."
        KeyTextBox.PlaceholderColor3 = CorDestaque
        task.delay(1.5, function()
            KeyTextBox.PlaceholderText = "Insert Validation Token"
            KeyTextBox.PlaceholderColor3 = Color3.fromRGB(90, 70, 70)
        end)
    end
end)

BackBtn.MouseButton1Click:Connect(function()
    SequenciaBotoes = ""
    KeyFrame.Visible = false
    setGaleriaVisibilidade(true)
    atualizarGaleria()
end)

SwitchBtn.MouseButton1Click:Connect(function()
    if not KeyDesbloqueada then return end

    ModoSecretoAtivo = not ModoSecretoAtivo
    if ModoSecretoAtivo then
        if TipoKeyAtivada == "All" then
            listaDeImagens = {}
            for _, v in ipairs(listaDeImagensNormais) do table.insert(listaDeImagens, v) end
            for _, v in ipairs(listaDeImagensSecretas) do table.insert(listaDeImagens, v) end
            for _, v in ipairs(listaDeImagensPremium) do table.insert(listaDeImagens, v) end
            SwitchBtn.Text = "All Unlocked"
        else
            listaDeImagens = listaDeImagensSecretas
            SwitchBtn.Text = "Secrets"
        end
    else
        listaDeImagens = listaDeImagensNormais
        SwitchBtn.Text = "Normals"
    end
    indiceAtual = 1
    atualizarGaleria()
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.RightControl then
        if MainFrame.Visible then
            MainFrame.Visible = false
            OpenButton.Visible = true
        else
            MainFrame.Visible = true
            OpenButton.Visible = false
        end
    end
end)

-- DRAG SYSTEM IMAGENS
local imgArrastando = false
local decolagemMouse = nil
local posInicialImg = nil

ExibicaoImagem.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and escalaZoom > 1.0 then
        imgArrastando = true
        decolagemMouse = input.Position
        posInicialImg = Vector2.new(ExibicaoImagem.Position.X.Offset, ExibicaoImagem.Position.Y.Offset)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                imgArrastando = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if imgArrastando and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - decolagemMouse
        ExibicaoImagem.Position = UDim2.new(0.5, posInicialImg.X + delta.X, 0.5, posInicialImg.Y + delta.Y)
        ajustarLimitesPosicao()
    end
end)

-- DRAG SYSTEM HUB
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ENTRADA EM AÇÃO
iniciarProcesso()
